import Foundation

class EventsViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // TODO: Replace with your actual Google Calendar API key and Calendar ID
    private let apiKey = "YOUR_GOOGLE_API_KEY"
    private let calendarId = "YOUR_CALENDAR_ID"

    private var cachedEvents: [CalendarEvent] = []
    private var lastFetch: Date?
    private let cacheInterval: TimeInterval = 300 // 5 minutes

    func fetchEvents(forceRefresh: Bool = false) {
        // Use cache if available and fresh
        if !forceRefresh, let lastFetch = lastFetch,
           Date().timeIntervalSince(lastFetch) < cacheInterval,
           !cachedEvents.isEmpty {
            self.events = cachedEvents
            return
        }

        isLoading = true
        errorMessage = nil

        let now = ISO8601DateFormatter().string(from: Date())
        let encodedCalendarId = calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId

        let urlString = "https://www.googleapis.com/calendar/v3/calendars/\(encodedCalendarId)/events?key=\(apiKey)&timeMin=\(now)&maxResults=25&singleEvents=true&orderBy=startTime"

        guard let url = URL(string: urlString) else {
            self.isLoading = false
            self.errorMessage = "Invalid calendar URL"
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let calendarResponse = try decoder.decode(GoogleCalendarResponse.self, from: data)
                    let parsed = (calendarResponse.items ?? []).compactMap { CalendarEvent.from($0) }
                    self?.events = parsed
                    self?.cachedEvents = parsed
                    self?.lastFetch = Date()
                } catch {
                    self?.errorMessage = "Failed to parse events: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
