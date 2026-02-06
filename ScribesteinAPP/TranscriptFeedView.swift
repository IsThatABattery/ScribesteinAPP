import SwiftUI

struct TranscriptFeedView: View {
    @StateObject private var viewModel = TranscriptViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
			ScrollView {
				LazyVStack(spacing: 0) {
					ForEach(viewModel.transcripts) { transcript in
						TranscriptRow(transcript: transcript)
					}
				}
			}
            .background(SColor.background.ignoresSafeArea())
            .navigationTitle("Transcripts")
			.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        if authViewModel.isAdmin {
                            NavigationLink(destination: AdminSettingsView()) {
                                Image(systemName: "gearshape.fill")
                            }
                        }
                        if authViewModel.isExecUser || authViewModel.isAdmin {
                            NavigationLink(destination: ExecView()) {
                                Image(systemName: "briefcase.fill")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .buttonStyle(SButtonTertiary())
                }
            }
            .onAppear {
                viewModel.fetchFromCache()
                viewModel.subscribeToTranscripts()
            }
        }
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
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(transcript.transcript)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(SColor.text)
                    HStack(spacing: 12) {
                        Text(transcript.formattedTimestamp)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(SColor.textSecondary)
                        Text(transcript.formattedConfidence)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(SColor.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, SSpace.l.rawValue)
            .padding(.vertical, SSpace.m.rawValue)

            Rectangle()
                .fill(SColor.stroke)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
    }
}
