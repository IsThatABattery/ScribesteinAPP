import SwiftUI

struct TranscriptFeedView: View {
    @StateObject private var viewModel = TranscriptViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear

                ScrollView {
                    LazyVStack(spacing: SSpace.s.rawValue) {
                        ForEach(viewModel.transcripts) { transcript in
                            TranscriptRow(transcript: transcript)
                        }
                    }
                    .padding(SSpace.m.rawValue)
                }
            }
            .navigationTitle("Transcripts")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchFromCache()
                viewModel.subscribeToTranscripts()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct TranscriptFeedView_Previews: PreviewProvider {
    static var previews: some View {
        TranscriptFeedView()
            .environmentObject(AuthViewModel())
    }
}

struct TranscriptRow: View {
    let transcript: Transcript
    var body: some View {
        GlassCard(padding: SSpace.m.rawValue) {
            VStack(alignment: .leading, spacing: SSpace.xs.rawValue) {
                Text(transcript.transcript)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(SColor.text)

                HStack(spacing: SSpace.s.rawValue) {
                    Label(transcript.formattedTimestamp, systemImage: "clock")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(SColor.textSecondary)

                    Spacer()

                    Text(transcript.formattedConfidence)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(SColor.textMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .glassBackground(cornerRadius: SRadius.tight.rawValue)
                }
            }
        }
    }
}
