//
//  LandingPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI

struct LandingPage: View {
    @State private var showAddMemory = false

    var body: some View {
        TabView {
            Tab("Calendar", systemImage: "calendar") {
                MemoriesCalendarPage(onAdd: { showAddMemory = true })
            }
            Tab("Memories", systemImage: "photo.on.rectangle.angled") {
                MemoriesListPage(onAdd: { showAddMemory = true })
            }
        }
        .sheet(isPresented: $showAddMemory) {
            AddMemoryPage()
        }
    }
}

#Preview {
    LandingPage()
        .environment(MemoryStore())
        .tint(Theme.accent)
}
