//
//  MemoryData.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import Foundation

struct MemoryData {
    static let memories: [MemoryModel] = [
        MemoryModel(
            title: "Beach Day",
            location: "Bali, Nusa Dua Beach",
            description: "Going to the beach in Bali, called Nusa Dua Beach",
            date: Date.daysAgo(14),
            imageName: "beach",
            categories: ["Beach", "Travel", "Holiday"]
        ),
        
        MemoryModel(
            title: "Mountain Trip",
            location: "Japan, Mt. Fuji",
            description: "Such an amazing view during my visit in Japan, it's Mt. Fuji",
            date: Date.daysAgo(10),
            imageName: "mountain",
            categories: ["Mountain", "Nature", "Travel"]
        ),
        
        MemoryModel(
            title: "City Night Walk",
            location: "Japan, Shibuya Tokyo",
            description: "Walking around Shibuya crossing at night was incredible. The lights, crowds, and atmosphere were unforgettable.",
            date: Date.daysAgo(9),
            imageName: "city",
            categories: ["City", "Night", "Japan"]
        ),
        
        MemoryModel(
            title: "Temple Visit",
            location: "Japan, Kyoto Temple",
            description: "Visited a beautiful temple in Kyoto surrounded by maple trees and traditional architecture.",
            date: Date.daysAgo(7),
            imageName: "temple",
            categories: ["Temple", "Culture", "Japan"]
        ),
        
        MemoryModel(
            title: "Forest Hiking",
            location: "Indonesia, Ubud Forest",
            description: "A peaceful hiking trip through the forest in Ubud. The air was fresh and the scenery was calming.",
            date: Date.daysAgo(5),
            imageName: "forest",
            categories: ["Forest", "Hiking", "Nature"]
        ),
        
        MemoryModel(
            title: "Coffee Morning",
            location: "Indonesia, Bali Cafe",
            description: "Started the day with a cup of coffee at a cozy cafe while watching the morning rain.",
            date: Date.daysAgo(4),
            imageName: "coffee",
            categories: ["Cafe", "Coffee", "Relax"]
        ),
        
        MemoryModel(
            title: "Sunset Cliff",
            location: "Indonesia, Uluwatu",
            description: "Watched the sunset from the cliffs of Uluwatu. The sky turned orange and purple over the ocean.",
            date: Date.daysAgo(2),
            imageName: "sunset",
            categories: ["Sunset", "Beach", "Nature"]
        )
    ]
}
