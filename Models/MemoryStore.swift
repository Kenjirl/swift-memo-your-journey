//
//  MemoryStore.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import Foundation
import Observation

@Observable
final class MemoryStore {
    private(set) var memories: [MemoryModel]

    init(memories: [MemoryModel] = MemoryData.memories) {
        self.memories = memories.sorted { $0.date > $1.date }
    }

    func add(_ memory: MemoryModel) {
        memories.append(memory)
        memories.sort { $0.date > $1.date }
    }

    /// Replaces the memory with the same id.
    func update(_ memory: MemoryModel) {
        guard let index = memories.firstIndex(where: { $0.id == memory.id }) else { return }
        memories[index] = memory
        memories.sort { $0.date > $1.date }
        PhotoCache.removeAll()
    }

    func delete(_ memory: MemoryModel) {
        memories.removeAll { $0.id == memory.id }
    }

    func memories(on day: Date) -> [MemoryModel] {
        memories.filter { Calendar.app.isDate($0.date, inSameDayAs: day) }
    }

    var placeCount: Int { locations.count }

    var countryCount: Int { Set(memories.map(\.country).filter { !$0.isEmpty }).count }

    /// Categories ordered by how often they are used.
    var categories: [String] { Self.byFrequency(memories.flatMap(\.categories)) }

    /// Places ordered by how often they are used.
    var locations: [String] { Self.byFrequency(memories.map(\.location).filter { !$0.isEmpty }) }

    private static func byFrequency(_ values: [String]) -> [String] {
        var counts: [String: Int] = [:]
        for value in values {
            counts[value, default: 0] += 1
        }
        return counts.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }.map(\.key)
    }
}
