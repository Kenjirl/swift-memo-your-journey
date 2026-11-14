//
//  Memo_Your_JourneyApp.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI

@main
struct Memo_Your_JourneyApp: App {
    @State private var store = MemoryStore()

    var body: some Scene {
        WindowGroup {
            LandingPage()
                .environment(store)
                .tint(Theme.accent)
        }
    }
}
