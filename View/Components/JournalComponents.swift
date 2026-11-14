//
//  JournalComponents.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import SwiftUI
import UIKit

/// Shows one of a memory's photos (index 0 = cover) filling its frame.
/// Falls back to the bundled sample image, then to a placeholder.
struct MemoryPhoto: View {
    let memory: MemoryModel
    var index: Int = 0

    var body: some View {
        Color.clear
            .overlay { content }
            .clipped()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        if index < memory.photos.count,
           let image = PhotoCache.image(for: memory.photos[index], key: "\(memory.id)-\(index)") {
            Image(uiImage: image).resizable().scaledToFill()
        } else if index == 0, !memory.imageName.isEmpty {
            Image(memory.imageName).resizable().scaledToFill()
        } else {
            ZStack {
                Theme.pill
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(Theme.muted)
            }
        }
    }
}

/// Selected value with a remove button, used by `TokenSearchField`.
struct TokenChip: View {
    let text: String
    var systemImage: String? = nil
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .foregroundStyle(Theme.accentText)
            }
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Theme.muted)
                    .frame(width: 22, height: 22)
                    .background(Theme.surface.opacity(0.7), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(text)")
        }
        .padding(.leading, 12)
        .padding(.trailing, 6)
        .frame(minHeight: 36)
        .background(Theme.pill, in: Capsule())
    }
}

/// Large serif title with an optional eyebrow and the round "+" button.
struct PageHeader: View {
    var eyebrow: String? = nil
    let title: String
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.semibold))
                        .tracking(1.4)
                        .foregroundStyle(Theme.muted)
                }
                Text(title)
                    .font(.serif(34))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            AddMemoryButton(action: onAdd)
        }
    }
}

struct AddMemoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Theme.accent, in: Circle())
        }
        .accessibilityLabel("Add memory")
    }
}

/// Small rounded label used for the stats row.
struct StatPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.ink.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Theme.pill, in: Capsule())
    }
}

/// Colored category chip, tinted per category.
struct CategoryChip: View {
    let category: String

    var body: some View {
        let colors = CategoryPalette.colors(for: category)
        Text(category)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(colors.fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colors.bg, in: Capsule())
    }
}

/// Selectable filter / tag chip: dark when selected, outlined otherwise.
struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Theme.background : Theme.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 36)
                .background(isSelected ? Theme.ink : Theme.surface, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(isSelected ? Color.clear : Theme.line, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// "pin + location" line.
struct LocationLabel: View {
    let text: String
    var color: Color = Theme.muted

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: "mappin.and.ellipse")
        }
        .labelStyle(CompactLabelStyle())
        .foregroundStyle(color)
    }
}

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon.imageScale(.small)
            configuration.title
        }
    }
}

/// Compact row card: thumbnail, serif title, location.
struct MemoryRowCard: View {
    let memory: MemoryModel

    var body: some View {
        HStack(spacing: 14) {
            MemoryPhoto(memory: memory)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(memory.title)
                    .font(.serif(18))
                    .foregroundStyle(Theme.ink)
                if !memory.displayLocation.isEmpty {
                    LocationLabel(text: memory.displayLocation)
                        .font(.footnote)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.muted.opacity(0.7))
        }
        .padding(10)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.shadow.opacity(0.06), radius: 1, y: 1)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

/// Full-width photo card with title over a soft scrim and a date badge.
struct MemoryPhotoCard: View {
    let memory: MemoryModel

    var body: some View {
        MemoryPhoto(memory: memory)
            .frame(height: 214)
            .frame(maxWidth: .infinity)
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.7)],
                    startPoint: UnitPoint(x: 0.5, y: 0.4),
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.serif(24))
                        .foregroundStyle(.white)
                    let subtitle = [memory.displayLocation, memory.categories.first ?? ""]
                        .filter { !$0.isEmpty }
                        .joined(separator: " · ")
                    if !subtitle.isEmpty {
                        LocationLabel(text: subtitle, color: .white.opacity(0.92))
                            .font(.footnote.weight(.medium))
                    }
                }
                .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                if memory.photoCount > 1 {
                    Label("\(memory.photoCount)", systemImage: "photo.stack")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(12)
                }
            }
            .overlay(alignment: .topLeading) {
                VStack(spacing: 0) {
                    Text(memory.date.shortMonth())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Color(light: 0x8F3F1E, dark: 0x8F3F1E))
                    Text(memory.date.dayNumber())
                        .font(.serif(20, .bold))
                        .foregroundStyle(Color(light: 0x2A211B, dark: 0x2A211B))
                }
                .frame(width: 46)
                .padding(.vertical, 6)
                .background(Color(light: 0xFBF6EE, dark: 0xFBF6EE).opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(memory.title), \(memory.displayLocation), \(memory.date.toFormattedString())")
    }
}
