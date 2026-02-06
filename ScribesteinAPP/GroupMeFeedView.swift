import SwiftUI

struct GroupMeFeedView: View {
    @StateObject private var viewModel = GroupMeViewModel()
    @State private var selectedSegment: FeedSegment = .all

    enum FeedSegment: String, CaseIterable {
        case all = "All"
        case announcements = "Announcements"
        case polls = "Polls"
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear

                VStack(spacing: 0) {
                    // Segment picker
                    Picker("Feed", selection: $selectedSegment) {
                        ForEach(FeedSegment.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, SSpace.m.rawValue)
                    .padding(.vertical, SSpace.s.rawValue)

                    // Content
                    Group {
                        if isEmpty {
                            emptyState
                        } else {
                            ScrollView {
                                LazyVStack(spacing: SSpace.s.rawValue) {
                                    if selectedSegment == .all || selectedSegment == .polls {
                                        ForEach(activePolls) { poll in
                                            PollCard(poll: poll)
                                        }
                                    }

                                    if selectedSegment == .all || selectedSegment == .announcements {
                                        ForEach(viewModel.announcements) { announcement in
                                            AnnouncementCard(announcement: announcement)
                                        }
                                    }

                                    if selectedSegment == .all || selectedSegment == .polls {
                                        let expired = expiredPolls
                                        if !expired.isEmpty {
                                            Text("Past Polls")
                                                .sectionHeaderStyle()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, SSpace.s.rawValue)

                                            ForEach(expired) { poll in
                                                PollCard(poll: poll)
                                            }
                                        }
                                    }
                                }
                                .padding(SSpace.m.rawValue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.subscribe()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Computed

    private var activePolls: [Poll] {
        viewModel.polls.filter { $0.isActive }
    }

    private var expiredPolls: [Poll] {
        viewModel.polls.filter { !$0.isActive }
    }

    private var isEmpty: Bool {
        switch selectedSegment {
        case .all:
            return viewModel.announcements.isEmpty && viewModel.polls.isEmpty
        case .announcements:
            return viewModel.announcements.isEmpty
        case .polls:
            return viewModel.polls.isEmpty
        }
    }

    private var emptyState: some View {
        VStack(spacing: SSpace.m.rawValue) {
            Spacer()
            Image(systemName: selectedSegment == .polls ? "chart.bar.xaxis" : "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundStyle(SColor.textMuted)
            Text("No \(selectedSegment.rawValue.lowercased()) yet")
                .font(.headline)
                .foregroundStyle(SColor.text)
            Text("Announcements and polls from your GroupMe group will appear here.")
                .font(.subheadline)
                .foregroundStyle(SColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SSpace.xl.rawValue)
            Spacer()
        }
    }
}

// MARK: - Announcement Card

struct AnnouncementCard: View {
    let announcement: Announcement

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                HStack(spacing: SSpace.s.rawValue) {
                    // Avatar placeholder
                    Circle()
                        .fill(SColor.blue.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(announcement.senderName.prefix(1)).uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(SColor.blue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(announcement.senderName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SColor.text)
                        Text(announcement.formattedDate)
                            .font(.caption)
                            .foregroundStyle(SColor.textMuted)
                    }

                    Spacer()

                    // Announcement badge
                    Text("ANNOUNCEMENT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(SColor.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .glassBackground(cornerRadius: SRadius.tight.rawValue, borderColor: SColor.glassBorderGold)
                }

                Text(announcement.text)
                    .font(.body)
                    .foregroundStyle(SColor.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Poll Card

struct PollCard: View {
    let poll: Poll

    var body: some View {
        GlassCard(borderColor: poll.isActive ? SColor.glassBorderGold : SColor.glassBorder) {
            VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                // Header
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundStyle(poll.isActive ? SColor.accent : SColor.textMuted)

                    Text("Poll")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SColor.textSecondary)

                    if poll.isActive {
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(SColor.success)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SColor.success.opacity(0.15), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }

                    Spacer()

                    if let owner = poll.ownerName {
                        Text(owner)
                            .font(.caption)
                            .foregroundStyle(SColor.textMuted)
                    }
                }

                // Subject
                Text(poll.subject)
                    .font(.headline)
                    .foregroundStyle(SColor.text)
                    .fixedSize(horizontal: false, vertical: true)

                // Options
                VStack(spacing: SSpace.xs.rawValue) {
                    ForEach(poll.options) { option in
                        HStack {
                            Image(systemName: poll.type == "multi" ? "square" : "circle")
                                .font(.caption)
                                .foregroundStyle(SColor.textMuted)
                            Text(option.title)
                                .font(.subheadline)
                                .foregroundStyle(SColor.text)
                            Spacer()
                        }
                        .padding(.vertical, SSpace.xs.rawValue)
                        .padding(.horizontal, SSpace.s.rawValue)
                        .glassBackground(cornerRadius: SRadius.tight.rawValue)
                    }
                }

                // Footer
                HStack {
                    if let expText = poll.expirationText {
                        Label(expText, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(poll.isActive ? SColor.textSecondary : SColor.textMuted)
                    }
                    Spacer()
                    Text(poll.formattedDate)
                        .font(.caption)
                        .foregroundStyle(SColor.textMuted)
                }
            }
        }
    }
}

struct GroupMeFeedView_Previews: PreviewProvider {
    static var previews: some View {
        GroupMeFeedView()
    }
}
