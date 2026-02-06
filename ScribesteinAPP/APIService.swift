import Foundation

class APIService {
    private let apiKey: String
    private let baseUrlString: String

    init(apiKey: String, baseUrlString: String) {
        self.apiKey = apiKey
        self.baseUrlString = baseUrlString
    }

    func getStatus(completion: @escaping (Result<String, Error>) -> Void) {
        request(endpoint: "/status", method: "GET", body: nil as String?, completion: completion)
    }

    func setVolume(level: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["level": level]
        request(endpoint: "/volume", method: "POST", body: body, completion: completion)
    }

    func adjustVolume(delta: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["delta": delta]
        request(endpoint: "/volume", method: "POST", body: body, completion: completion)
    }

    func setMute(mute: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["mute": mute]
        request(endpoint: "/mute", method: "POST", body: body, completion: completion)
    }

    func pause(target: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["target": target]
        request(endpoint: "/pause", method: "POST", body: body, completion: completion)
    }
    
    func play(target: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["target": target]
        request(endpoint: "/play", method: "POST", body: body, completion: completion)
    }

    func connectToSpeaker(macAddress: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ["speaker_mac": macAddress]
        request(endpoint: "/speaker/connect", method: "POST", body: body, completion: completion)
    }

    private func request<T: Encodable>(endpoint: String, method: String, body: T?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseUrlString + endpoint) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }

        print("Sending \(method) request to \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                }
            }
        }.resume()
    }
}
