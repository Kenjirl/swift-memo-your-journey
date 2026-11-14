//
//  MemoryModel.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import Foundation

struct MemoryModel: Identifiable, Hashable {
    /// Kept when a memory is edited, so screens showing it stay in sync.
    var id = UUID()
    var title: String
    var location: String
    var description: String
    var date: Date
    var imageName: String
    var photos: [Data] = []
    var categories: [String]

    // Identity is the id, so navigation does not hash photo data.
    static func == (lhs: MemoryModel, rhs: MemoryModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var country: String { Self.country(of: location) }

    var place: String {
        let parts = Self.parts(location)
        return parts.count > 1 ? parts[1] : location
    }

    /// Shown exactly as typed ("Japan, Mt. Fuji"), so input and display always match.
    var displayLocation: String { location.trimmingCharacters(in: .whitespaces) }

    var photoCount: Int {
        photos.isEmpty ? (imageName.isEmpty ? 0 : 1) : photos.count
    }

    // MARK: - "Country, Place" helpers

    private static func parts(_ location: String) -> [String] {
        location.split(separator: ",", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// The part before the first comma: "Japan, Mt. Fuji" → "Japan".
    static func country(of location: String) -> String {
        parts(location).first ?? location
    }
}
