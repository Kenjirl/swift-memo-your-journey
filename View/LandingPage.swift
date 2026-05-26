//
//  LandingPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI

struct LandingPage: View {
    @State private var selection = 1
    @State private var showAddMemory = false
    
    @State private var memories = MemoryData.memories
        .sorted { $0.date > $1.date }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            TabView(selection: $selection) {
                MemoriesCalendarPage(memories: $memories)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)

                MemoriesListPage(memories: $memories)
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                    .tag(2)
            }

            Button {
                showAddMemory = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(20)
            
            .sheet(isPresented: $showAddMemory) {
                AddMemoryPage()
            }
        }
    }
}

#Preview {
    LandingPage()
}
