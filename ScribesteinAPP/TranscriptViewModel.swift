import Foundation
import FirebaseFirestore

class TranscriptViewModel: ObservableObject {
    @Published var transcripts = [Transcript]()
    private var db = Firestore.firestore(database: "transcripts")

    func fetchFromCache() {
        let query = db.collection("transcripts").order(by: "timestamp", descending: true)
        
        query.getDocuments(source: .cache) { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                self.transcripts = documents.compactMap { document -> Transcript? in
                    try? document.data(as: Transcript.self)
                }
            }
        }
    }

    func subscribeToTranscripts() {
        db.collection("transcripts")
          .order(by: "timestamp", descending: true)
          .addSnapshotListener { querySnapshot, error in
              guard let documents = querySnapshot?.documents else {
                  print("Error fetching documents: \(error!)")
                  return
              }
              
              let newTranscripts = documents.compactMap { queryDocumentSnapshot -> Transcript? in
                  try? queryDocumentSnapshot.data(as: Transcript.self)
              }
              
              if self.transcripts != newTranscripts {
                  self.transcripts = newTranscripts
              }
          }
    }
}
