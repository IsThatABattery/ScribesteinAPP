import Foundation
import FirebaseFirestore

struct Announcement: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let senderName: String
    let senderAvatar: String?
    let text: String
    let createdAt: Timestamp

    var formattedDate: String {
        let date = createdAt.dateValue()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var formattedFullDate: String {
        let date = createdAt.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
