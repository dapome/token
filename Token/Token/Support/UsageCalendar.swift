import Foundation

enum UsageCalendar {
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    static func dayStart(containing date: Date) -> Date {
        utc.startOfDay(for: date)
    }

    static func monthStart(containing date: Date) -> Date {
        guard let interval = utc.dateInterval(of: .month, for: date) else {
            return dayStart(containing: date)
        }

        return interval.start
    }

    static func unixTimestampString(for date: Date) -> String {
        String(Int(date.timeIntervalSince1970.rounded(.down)))
    }

    static func rfc3339String(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = utc.timeZone
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}
