import SwiftUI

struct ExecView: View {
    @StateObject private var viewModel = ExecViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: SSpace.l.rawValue) {
                    
                    if let response = viewModel.responseText {
                        VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                            Text("Response")
                                .font(.headline)
                                .foregroundStyle(SColor.textSecondary)
                            Text(response)
                                .font(.body)
                                .foregroundStyle(SColor.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(SColor.surface)
                        .cornerRadius(SRadius.standard.rawValue)
                    }

                    // System Section
                    VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                        Text("System")
                            .font(.headline)
                            .foregroundStyle(SColor.textSecondary)
                        Button("Get System Status") {
                            viewModel.getSystemStatus()
                        }
                        .buttonStyle(SButtonSecondary())
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(SColor.surface)
                    .cornerRadius(SRadius.standard.rawValue)
                    
                    // Volume Section
                    VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                        Text("Volume")
                            .font(.headline)
                            .foregroundStyle(SColor.textSecondary)
                        HStack {
                            TextField("Level (0-100)", text: $viewModel.volumeLevel)
                                .keyboardType(.numberPad)
                                .sInputStyle()
                            Button("Set") {
                                viewModel.setVolume()
                            }
                            .buttonStyle(SButtonPrimary())
                        }
                        HStack {
                            TextField("Delta (±N)", text: $viewModel.volumeDelta)
                                .keyboardType(.numberPad)
                                .sInputStyle()
                            Button("Adjust") {
                                viewModel.adjustVolume()
                            }
                            .buttonStyle(SButtonPrimary())
                        }
                    }
                    .padding()
                    .background(SColor.surface)
                    .cornerRadius(SRadius.standard.rawValue)
                    
                    // Mute Section
                    VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                        Text("Mute")
                            .font(.headline)
                            .foregroundStyle(SColor.textSecondary)
                        Toggle("Mute", isOn: $viewModel.isMuted)
                            .onChange(of: viewModel.isMuted) { _, newValue in
                                viewModel.setMute(mute: newValue)
                            }
                            .tint(SColor.accent)
                    }
                    .padding()
                    .background(SColor.surface)
                    .cornerRadius(SRadius.standard.rawValue)
                    
                    // Playback Section
                    VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                        Text("Playback")
                            .font(.headline)
                            .foregroundStyle(SColor.textSecondary)
                        HStack(spacing: SSpace.s.rawValue) {
                            Button("Pause Source") { viewModel.pause(target: "source") }
                                .buttonStyle(SButtonSecondary())
                                .frame(maxWidth: .infinity)
                            Button("Play Source") { viewModel.play(target: "source") }
                                .buttonStyle(SButtonPrimary())
                                .frame(maxWidth: .infinity)
                        }
                        HStack(spacing: SSpace.s.rawValue) {
                            Button("Pause Bridge") { viewModel.pause(target: "bridge") }
                                .buttonStyle(SButtonSecondary())
                                .frame(maxWidth: .infinity)
                            Button("Play Bridge") { viewModel.play(target: "bridge") }
                                .buttonStyle(SButtonPrimary())
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(SColor.surface)
                    .cornerRadius(SRadius.standard.rawValue)
                    
                    // Speaker Section
                    VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                        Text("Speaker")
                            .font(.headline)
                            .foregroundStyle(SColor.textSecondary)
                        HStack {
                            TextField("Speaker MAC Address", text: $viewModel.speakerMac)
                                .sInputStyle()
                            Button("Connect") {
                                viewModel.connectToSpeaker()
                            }
                            .buttonStyle(SButtonPrimary())
                        }
                    }
                    .padding()
                    .background(SColor.surface)
                    .cornerRadius(SRadius.standard.rawValue)
                    
                }
                .padding()
            }
            .background(SColor.background.ignoresSafeArea())
            .navigationTitle("Exec Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Exec Controls")
                        .font(.headline)
                        .foregroundColor(SColor.text)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

class ExecViewModel: ObservableObject {
    @Published var volumeLevel: String = ""
    @Published var volumeDelta: String = ""
    @Published var isMuted: Bool = false
    @Published var speakerMac: String = ""
    @Published var responseText: String?

    private let apiService: APIService

    init() {
        // IMPORTANT: Replace with your actual API key
        let apiKey = "your-api-key" 
        let baseUrl = "http://aerpi.local:8000/api/v1"
        self.apiService = APIService(apiKey: apiKey, baseUrlString: baseUrl)
    }

    private func handleResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let response):
            self.responseText = response
        case .failure(let error):
            self.responseText = "Error: \(error.localizedDescription)"
        }
    }

    func getSystemStatus() {
        apiService.getStatus(completion: handleResult)
    }

    func setVolume() {
        if let level = Int(volumeLevel) {
            apiService.setVolume(level: level, completion: handleResult)
        }
    }

    func adjustVolume() {
        if let delta = Int(volumeDelta) {
            apiService.adjustVolume(delta: delta, completion: handleResult)
        }
    }

    func setMute(mute: Bool) {
        apiService.setMute(mute: mute, completion: handleResult)
    }

    func pause(target: String) {
        apiService.pause(target: target, completion: handleResult)
    }

    func play(target: String) {
        apiService.play(target: target, completion: handleResult)
    }

    func connectToSpeaker() {
        apiService.connectToSpeaker(macAddress: speakerMac, completion: handleResult)
    }
}

struct ExecView_Previews: PreviewProvider {
    static var previews: some View {
        ExecView()
    }
}
