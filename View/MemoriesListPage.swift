//
//  MemoriesListPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI

struct MemoriesListPage: View {
    @Binding var memories: [MemoryModel]
    
    var filteredMemories: [MemoryModel] {
        if searchText.isEmpty {
            return memories
        }
        
        return memories.filter { memory in
            memory.title.localizedCaseInsensitiveContains(searchText) ||
            memory.location.localizedCaseInsensitiveContains(searchText) ||
            memory.categories.contains {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @State private var date = Date()
    var formattedDate: String {
        date.formatted(.dateTime.month(.wide).day().year())
    }
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            // List of Memories
            List {
                ForEach(filteredMemories) { memory in
                    NavigationLink {
                        DetailMemoryPage(memory: memory)
                    } label: {
                        VStack (alignment: .leading) {
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
                                    
                                    Text(memory.location)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(memory.categories, id: \.self) { category in
                                        Text(category)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.5))
                                            .cornerRadius(8)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("Memories")
            .listStyle(.insetGrouped)
            .listRowSpacing(12)
            .searchable(text: $searchText, prompt: "Search memories")
        }
    }
}

//#Preview {
//    MemoriesListPage(memories: MemoryModel, date: <#T##arg#>, searchText: <#T##String#>)
//}
