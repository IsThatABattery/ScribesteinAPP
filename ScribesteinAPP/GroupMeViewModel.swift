import Foundation
import FirebaseFirestore

class GroupMeViewModel: ObservableObject {
    @Published var announcements: [Announcement] = []
    @Published var polls: [Poll] = []

    private var db = Firestore.firestore()
    private var announcementListener: ListenerRegistration?
    private var pollListener: ListenerRegistration?

    func subscribe() {
        subscribeToAnnouncements()
        subscribeToPolls()
    }

    private func subscribeToAnnouncements() {
        announcementListener?.remove()
        announcementListener = db.collection("groupme_announcements")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching announcements: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                let parsed = documents.compactMap { doc -> Announcement? in
                    try? doc.data(as: Announcement.self)
                }
                if self?.announcements != parsed {
                    self?.announcements = parsed
                }
            }
    }

    private func subscribeToPolls() {
        pollListener?.remove()
        pollListener = db.collection("groupme_polls")
            .order(by: "createdAt", descending: true)
            .limit(to: 25)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching polls: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                let parsed = documents.compactMap { doc -> Poll? in
                    try? doc.data(as: Poll.self)
                }
                if self?.polls != parsed {
                    self?.polls = parsed
                }
            }
    }

    deinit {
        announcementListener?.remove()
        pollListener?.remove()
    }
}
