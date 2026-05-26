//
//  MemoriesCalendarPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 13/03/26.
//

import SwiftUI

struct MemoriesCalendarPage: View {
    @Binding var memories: [MemoryModel]
    
    @State private var date = Date()
    var formattedDate: String {
        date.formatted(.dateTime.month(.wide).day().year())
    }
    
    var filteredMemories: [MemoryModel] {
        memories.filter { memory in
            Calendar.current.isDate(memory.date, inSameDayAs: date)
        }
    }
    
    func deleteMemory(at offsets: IndexSet) {
        for index in offsets {
            let memory = filteredMemories[index]
            memories.removeAll { $0.id == memory.id }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Your Memories",
                    selection: $date,
                    displayedComponents: [.date]
                ).datePickerStyle(.graphical)	
                
                // List of Memories
                List {
                    if filteredMemories.isEmpty {
                        Text("No memories on \(formattedDate)")
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(filteredMemories) { memory in
                            NavigationLink {
                                DetailMemoryPage(memory: memory)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(memory.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading) {
                                        Text(memory.title)
                                            .font(.headline)
                                        
                                        Text(memory.date.toFormattedString())
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteMemory)
                    }
                }
                .listStyle(.insetGrouped)
                .listRowSpacing(12)
            }
        }
    }
}

//#Preview {
//    MemoriesCalendarPage()
//}
