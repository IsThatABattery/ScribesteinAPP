 import FirebaseFirestore

struct Transcript: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let transcript: String
    let timestamp: Timestamp
    let confidence: Double
    
    var formattedTimestamp: String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedConfidence: String {
        String(format: "%.1f%%", confidence * 100.0)
    }
}
