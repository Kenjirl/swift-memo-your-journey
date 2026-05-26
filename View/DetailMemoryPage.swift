//
//  DetailMemoryPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import SwiftUI

struct DetailMemoryPage: View {
    let memory: MemoryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if (memory.imageName != "") {
                Image(memory.imageName)
                    .resizable()
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(16)
            }
            
            Text(memory.date.toFormattedString())
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()
            
                
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
            
            Text(memory.description)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
        }
        .padding()
        .navigationTitle(memory.title)
    }
}

#Preview {
    NavigationStack {
        DetailMemoryPage(
            memory: MemoryModel(
                title: "Beach Day",
                location: "Bali, Nusa Dua Beach",
                description: "Today I visited the beach and enjoyed the beautiful sunset. The waves were calm and the weather was perfect.",
                date: Date(),
                imageName: "sunset",
                categories: ["Test", "adsasdasd", "adsasdasd", "adsasdasd", "adsasdasd", "adsasdasd"]
            )
        )
    }
}
