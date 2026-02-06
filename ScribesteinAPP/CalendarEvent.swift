import Foundation

// MARK: - Google Calendar API Response Models

struct GoogleCalendarResponse: Codable {
    let items: [GoogleCalendarEvent]?
}

struct GoogleCalendarEvent: Codable {
    let id: String
    let summary: String?
    let description: String?
    let location: String?
    let start: GoogleCalendarDateTime?
    let end: GoogleCalendarDateTime?
    let htmlLink: String?
}

struct GoogleCalendarDateTime: Codable {
    let dateTime: String?  // For timed events (ISO 8601)
    let date: String?      // For all-day events (yyyy-MM-dd)
    let timeZone: String?
}

// MARK: - App Model

struct CalendarEvent: Identifiable {
    let id: String
    let summary: String
    let description: String?
    let location: String?
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let htmlLink: String?

    var formattedDate: String {
        let formatter = DateFormatter()
        if isAllDay {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }
        return formatter.string(from: startDate)
    }

    var formattedTime: String? {
        guard !isAllDay else { return "All Day" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        var time = formatter.string(from: startDate)
        if let end = endDate {
            time += " – " + formatter.string(from: end)
        }
        return time
    }

    var formattedDayMonth: (day: String, month: String) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        return (dayFormatter.string(from: startDate), monthFormatter.string(from: startDate).uppercased())
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(startDate)
    }

    // Parse from Google Calendar API response
    static func from(_ event: GoogleCalendarEvent) -> CalendarEvent? {
        guard let start = event.start else { return nil }

        let isAllDay = start.date != nil
        var startDate: Date?
        var endDate: Date?

        if let dateTimeStr = start.dateTime {
            startDate = ISO8601DateFormatter().date(from: dateTimeStr)
        } else if let dateStr = start.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            startDate = formatter.date(from: dateStr)
        }

        if let end = event.end {
            if let dateTimeStr = end.dateTime {
                endDate = ISO8601DateFormatter().date(from: dateTimeStr)
            } else if let dateStr = end.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                endDate = formatter.date(from: dateStr)
            }
        }

        guard let resolvedStart = startDate else { return nil }

        return CalendarEvent(
            id: event.id,
            summary: event.summary ?? "Untitled Event",
            description: event.description,
            location: event.location,
            startDate: resolvedStart,
            endDate: endDate,
            isAllDay: isAllDay,
            htmlLink: event.htmlLink
        )
    }
}
