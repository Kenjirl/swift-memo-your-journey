//
//  MasonryGrid.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import SwiftUI
import UIKit

struct MasonryGrid<Tile: View>: View {
    let memories: [MemoryModel]
    var spacing: CGFloat = 10
    @ViewBuilder let tile: (MemoryModel, CGFloat) -> Tile

    /// Height ÷ width for each tile. A repeating rhythm keeps the grid lively,
    /// and portrait photos always get a tall tile.
    private static func ratio(for memory: MemoryModel, at index: Int) -> CGFloat {
        let rhythm: [CGFloat] = [1.32, 1.0, 1.12, 1.42, 0.92, 1.22]
        let base = rhythm[index % rhythm.count]
        if let size = coverSize(of: memory), size.height > size.width * 1.1 {
            return max(base, 1.38)
        }
        return base
    }

    private static func coverSize(of memory: MemoryModel) -> CGSize? {
        if let data = memory.photos.first {
            return PhotoCache.image(for: data, key: "\(memory.id)-0")?.size
        }
        return memory.imageName.isEmpty ? nil : UIImage(named: memory.imageName)?.size
    }

    /// Places each tile in the currently shorter column, keeping the overall
    /// order roughly top-to-bottom, newest first.
    private var columns: (left: [(MemoryModel, CGFloat)], right: [(MemoryModel, CGFloat)]) {
        var left: [(MemoryModel, CGFloat)] = []
        var right: [(MemoryModel, CGFloat)] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        for (index, memory) in memories.enumerated() {
            let ratio = Self.ratio(for: memory, at: index)
            if leftHeight <= rightHeight {
                left.append((memory, ratio))
                leftHeight += ratio
            } else {
                right.append((memory, ratio))
                rightHeight += ratio
            }
        }
        return (left, right)
    }

    var body: some View {
        let columns = columns
        HStack(alignment: .top, spacing: spacing) {
            column(columns.left)
            column(columns.right)
        }
    }

    private func column(_ items: [(MemoryModel, CGFloat)]) -> some View {
        LazyVStack(spacing: spacing) {
            ForEach(items, id: \.0.id) { memory, ratio in
                tile(memory, ratio)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

/// Grid tile: photo, small date badge, and title over a soft scrim.
struct MemoryGridTile: View {
    let memory: MemoryModel
    /// Height ÷ width.
    let ratio: CGFloat

    private let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

    var body: some View {
        Color.clear
            .aspectRatio(1 / ratio, contentMode: .fit)
            .overlay { MemoryPhoto(memory: memory) }
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.68)],
                    startPoint: UnitPoint(x: 0.5, y: 0.45),
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(memory.title)
                        .font(.serif(16))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if !memory.location.isEmpty {
                        Text(memory.place)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                }
                .padding(12)
            }
            .overlay(alignment: .topLeading) {
                Text("\(memory.date.dayNumber()) \(memory.date.shortMonth())")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(light: 0x2A211B, dark: 0x2A211B))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color(light: 0xFBF6EE, dark: 0xFBF6EE).opacity(0.92), in: Capsule())
                    .padding(10)
            }
            .overlay(alignment: .topTrailing) {
                if memory.photoCount > 1 {
                    Label("\(memory.photoCount)", systemImage: "photo.stack")
                        .labelStyle(CompactLabelStyle())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(10)
                }
            }
            .clipShape(shape)
            .contentShape(shape)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(memory.title), \(memory.displayLocation), \(memory.date.toFormattedString())")
    }
}
