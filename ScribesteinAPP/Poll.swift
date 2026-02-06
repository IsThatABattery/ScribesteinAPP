import Foundation
import FirebaseFirestore

struct Poll: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let subject: String
    let options: [PollOption]
    let type: String           // "single" or "multi"
    let visibility: String     // "public" or "anonymous"
    let status: String         // "active" or "past"
    let expiration: Timestamp?
    let createdAt: Timestamp
    let ownerName: String?

    var isActive: Bool {
        guard status == "active" else { return false }
        if let exp = expiration {
            return exp.dateValue() > Date()
        }
        return true
    }

    var formattedDate: String {
        let date = createdAt.dateValue()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var expirationText: String? {
        guard let exp = expiration else { return nil }
        let date = exp.dateValue()
        if date < Date() {
            return "Expired"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Expires " + formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PollOption: Codable, Hashable, Identifiable {
    let id: String
    let title: String
}
