//
//  Date+Format.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import Foundation

extension Date {
    func toFormattedString() -> String {
        return self.formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
            .locale(Locale(identifier: "en_US")))
    }
    
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }

    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
}
