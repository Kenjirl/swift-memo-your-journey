//
//  Date+Format.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import Foundation

extension Locale {
    static let app = Locale(identifier: "en_US")
}

extension Calendar {
    static let app: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .app
        calendar.timeZone = .current
        return calendar
    }()
}

extension Date {
    /// "November 6, 2026"
    func toFormattedString() -> String {
        formatted(.dateTime.month(.wide).day().year().locale(.app))
    }

    /// "Friday, November 6, 2026"
    func longString() -> String {
        formatted(.dateTime.weekday(.wide).month(.wide).day().year().locale(.app))
    }

    /// "Friday, November 6"
    func weekdayDayMonth() -> String {
        formatted(.dateTime.weekday(.wide).month(.wide).day().locale(.app))
    }

    /// "November 2026"
    func monthYear() -> String {
        formatted(.dateTime.month(.wide).year().locale(.app))
    }

    /// "NOV"
    func shortMonth() -> String {
        formatted(.dateTime.month(.abbreviated).locale(.app)).uppercased()
    }

    /// "6"
    func dayNumber() -> String {
        String(Calendar.app.component(.day, from: self))
    }

    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }

    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
