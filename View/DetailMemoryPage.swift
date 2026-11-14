//
//  DetailMemoryPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import SwiftUI

struct DetailMemoryPage: View {
    @Environment(MemoryStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let original: MemoryModel

    init(memory: MemoryModel) {
        original = memory
    }

    /// Always the latest version from the store, so edits show up right away.
    private var memory: MemoryModel {
        store.memories.first { $0.id == original.id } ?? original
    }

    @State private var confirmDelete = false
    @State private var isEditing = false
    @State private var photoPage: Int? = 0

    /// Tall, immersive photo; the title sits on top of it.
    private let heroHeight: CGFloat = 560

    private var galleryCount: Int { max(memory.photoCount, 1) }

    private var related: [MemoryModel] {
        guard !memory.country.isEmpty else { return [] }
        return Array(store.memories.filter { $0.id != memory.id && $0.country == memory.country }.prefix(6))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero

                content
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
            }
        }
        .background(Theme.background)
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: [memory.title, memory.displayLocation, memory.date.toFormattedString()].filter { !$0.isEmpty }.joined(separator: " — "))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil") {
                    isEditing = true
                }
                .accessibilityLabel("Edit memory")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit Memory", systemImage: "pencil") {
                        isEditing = true
                    }
                    Button("Delete Memory", systemImage: "trash", role: .destructive) {
                        confirmDelete = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More")
            }
        }
        .sheet(isPresented: $isEditing) {
            AddMemoryPage(editing: memory)
        }
        .onChange(of: memory.photoCount) {
            photoPage = 0
        }
        .confirmationDialog("Delete this memory?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(memory)
                dismiss()
            }
        }
    }

    // MARK: - Hero

    /// Full-bleed, swipeable gallery that stretches when pulled down,
    /// with tags and title laid over the photo.
    private var hero: some View {
        GeometryReader { proxy in
            let pull = max(0, proxy.frame(in: .scrollView).minY)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<galleryCount, id: \.self) { index in
                        MemoryPhoto(memory: memory, index: index)
                            .frame(width: proxy.size.width, height: heroHeight + pull)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $photoPage)
            .scrollDisabled(galleryCount < 2)
            .frame(height: heroHeight + pull)
            .overlay { heroScrims }
            .overlay(alignment: .bottomLeading) { heroTitle }
            .offset(y: -pull)
        }
        .frame(height: heroHeight)
    }

    /// Darkens the top for the nav buttons and the lower half for the title,
    /// then melts the photo into the page background.
    private var heroScrims: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 140)
            Spacer(minLength: 0)
            LinearGradient(colors: [.clear, .black.opacity(0.62)], startPoint: .top, endPoint: .bottom)
                .frame(height: 260)
            LinearGradient(colors: [.black.opacity(0.62), Theme.background], startPoint: .top, endPoint: .bottom)
                .frame(height: 36)
        }
        .allowsHitTesting(false)
    }

    private var heroTitle: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 6) {
                ForEach(memory.categories.prefix(3), id: \.self) { category in
                    Text(category)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay { Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1) }
                        .environment(\.colorScheme, .dark)
                }
                Spacer(minLength: 8)
                if galleryCount > 1 {
                    pageIndicator
                }
            }

            Text(memory.title)
                .font(.serif(38, .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 44)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<galleryCount, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index == (photoPage ?? 0) ? 1 : 0.5))
                    .frame(width: index == (photoPage ?? 0) ? 18 : 6, height: 6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.black.opacity(0.3), in: Capsule())
        .animation(.snappy, value: photoPage)
        .accessibilityElement()
        .accessibilityLabel("Photo \((photoPage ?? 0) + 1) of \(galleryCount)")
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            infoCard

            if !memory.description.isEmpty {
                Text(memory.description)
                    .font(.body)
                    .lineSpacing(5)
                    .foregroundStyle(Theme.ink.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !related.isEmpty {
                relatedSection
            }
        }
    }

    /// Place and date side by side in one card.
    private var infoCard: some View {
        HStack(spacing: 0) {
            if !memory.location.isEmpty {
                infoCell(label: "PLACE", icon: "mappin.and.ellipse", value: memory.displayLocation)
                Rectangle()
                    .fill(Theme.line)
                    .frame(width: 1)
            }
            infoCell(
                label: "DATE",
                icon: "calendar",
                value: memory.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year().locale(.app))
            )
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        }
    }

    private func infoCell(label: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(Theme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("More from \(memory.country)")
                .font(.headline)
                .foregroundStyle(Theme.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(related) { other in
                        NavigationLink(value: other) {
                            MemoryPhoto(memory: other)
                                .frame(width: 128, height: 88)
                                .overlay {
                                    LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                                }
                                .overlay(alignment: .bottomLeading) {
                                    Text(other.place.isEmpty ? other.title : other.place)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .padding(8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(other.title)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollClipDisabled()
        }
        .padding(.top, 22)
    }
}

#Preview {
    NavigationStack {
        DetailMemoryPage(memory: MemoryData.memories[2])
    }
    .environment(MemoryStore())
}
