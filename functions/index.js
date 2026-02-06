const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

// Environment config keys (set via firebase functions:config:set):
//   groupme.group_id       - GroupMe group ID
//   groupme.service_token  - GroupMe service account access token
//   groupme.bot_id         - GroupMe bot ID (optional, for sending messages)

/**
 * groupmeWebhook
 *
 * HTTP-triggered Cloud Function that receives GroupMe bot callback POSTs.
 * Processes incoming messages and writes announcements and polls to Firestore.
 *
 * Setup:
 * 1. Deploy this function
 * 2. Set the callback URL on your GroupMe bot to:
 *    https://<region>-<project>.cloudfunctions.net/groupmeWebhook
 * 3. Configure environment:
 *    firebase functions:config:set groupme.group_id="YOUR_GROUP_ID"
 *    firebase functions:config:set groupme.service_token="YOUR_SERVICE_TOKEN"
 *    firebase functions:config:set groupme.bot_id="YOUR_BOT_ID"
 */
exports.groupmeWebhook = functions.https.onRequest(async (req, res) => {
  // Only accept POST
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const message = req.body;

  // Ignore messages from bots to prevent loops
  if (message.sender_type === "bot") {
    return res.status(200).send("OK");
  }

  const attachments = message.attachments || [];
  const text = message.text || "";
  const senderName = message.name || "Unknown";
  const senderAvatar = message.avatar_url || null;
  const createdAt = message.created_at
    ? admin.firestore.Timestamp.fromMillis(message.created_at * 1000)
    : admin.firestore.Timestamp.now();
  const messageId = message.id || `msg_${Date.now()}`;

  try {
    // Check for poll attachments
    const pollAttachment = attachments.find((a) => a.type === "poll");
    if (pollAttachment && pollAttachment.poll_id) {
      await handlePoll(pollAttachment.poll_id, senderName, createdAt);
    }

    // Check for announcement pattern
    if (isAnnouncement(text, message)) {
      await handleAnnouncement(
        messageId,
        senderName,
        senderAvatar,
        text,
        attachments,
        createdAt
      );
    }

    return res.status(200).send("OK");
  } catch (error) {
    console.error("Error processing GroupMe message:", error);
    return res.status(500).send("Internal Server Error");
  }
});

/**
 * Determine if a message should be treated as an announcement.
 * Customize this logic based on your chapter's conventions.
 */
function isAnnouncement(text, message) {
  if (!text) return false;

  const lowerText = text.toLowerCase();

  // Check for announcement tags/patterns
  if (lowerText.includes("[announcement]")) return true;
  if (lowerText.includes("@everyone")) return true;
  if (lowerText.startsWith("announcement:")) return true;
  if (lowerText.startsWith("📢")) return true;

  // System messages that are announcements
  if (message.system === true) return true;

  return false;
}

/**
 * Fetch full poll details from GroupMe API and write to Firestore.
 */
async function handlePoll(pollId, ownerName, createdAt) {
  const config = functions.config();
  const groupId = config.groupme?.group_id;
  const serviceToken = config.groupme?.service_token;

  if (!groupId || !serviceToken) {
    console.error(
      "Missing GroupMe config. Set groupme.group_id and groupme.service_token"
    );
    return;
  }

  // Fetch poll details from GroupMe API
  const pollUrl = `https://api.groupme.com/v3/poll/${groupId}/${pollId}?token=${serviceToken}`;

  const response = await fetch(pollUrl);
  if (!response.ok) {
    console.error(
      `Failed to fetch poll ${pollId}: ${response.status} ${response.statusText}`
    );
    // Write a minimal poll record even if we can't fetch details
    await db
      .collection("groupme_polls")
      .doc(pollId)
      .set(
        {
          subject: "New Poll (details unavailable)",
          options: [],
          type: "single",
          visibility: "public",
          status: "active",
          expiration: null,
          createdAt: createdAt,
          ownerName: ownerName,
        },
        { merge: true }
      );
    return;
  }

  const data = await response.json();
  const poll = data.response?.poll || data.response || {};

  // Map poll options
  const options = (poll.options || []).map((opt) => ({
    id: opt.id || String(Math.random()),
    title: opt.title || "Untitled option",
  }));

  // Determine expiration
  let expiration = null;
  if (poll.expiration) {
    expiration = admin.firestore.Timestamp.fromMillis(
      poll.expiration * 1000
    );
  }

  // Write to Firestore
  await db
    .collection("groupme_polls")
    .doc(pollId)
    .set(
      {
        subject: poll.subject || "Untitled Poll",
        options: options,
        type: poll.type || "single",
        visibility: poll.visibility || "public",
        status: poll.status || "active",
        expiration: expiration,
        createdAt: createdAt,
        ownerName: ownerName,
      },
      { merge: true }
    );

  console.log(`Poll ${pollId} written to Firestore`);
}

/**
 * Write an announcement to Firestore.
 */
async function handleAnnouncement(
  messageId,
  senderName,
  senderAvatar,
  text,
  attachments,
  createdAt
) {
  // Clean up the text by removing the tag
  let cleanText = text
    .replace(/\[announcement\]/gi, "")
    .replace(/^announcement:/i, "")
    .replace(/^📢\s*/, "")
    .trim();

  if (!cleanText) {
    cleanText = text; // Fall back to original if cleaning removed everything
  }

  // Filter attachments to only include useful types
  const cleanAttachments = attachments
    .filter((a) => ["image", "location", "video"].includes(a.type))
    .map((a) => ({ type: a.type, url: a.url || null }));

  await db
    .collection("groupme_announcements")
    .doc(messageId)
    .set({
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: cleanText,
      createdAt: createdAt,
      attachments: cleanAttachments,
    });

  console.log(`Announcement ${messageId} written to Firestore`);
}
