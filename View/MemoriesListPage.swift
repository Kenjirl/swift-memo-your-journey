//
//  MemoriesListPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI

struct MemoriesListPage: View {
    @Environment(MemoryStore.self) private var store
    var onAdd: () -> Void

    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var editingMemory: MemoryModel?
    @AppStorage("memoriesLayout") private var layout: MemoriesLayout = .grid

    private var filteredMemories: [MemoryModel] {
        store.memories.filter { memory in
            let matchesCategory = selectedCategory.map { memory.categories.contains($0) } ?? true
            let query = searchText.trimmed
            let matchesSearch = query.isEmpty
                || memory.title.localizedCaseInsensitiveContains(query)
                || memory.location.localizedCaseInsensitiveContains(query)
                || memory.categories.contains { $0.localizedCaseInsensitiveContains(query) }
            return matchesCategory && matchesSearch
        }
    }

    /// Memories grouped by month, newest month first.
    private var sections: [MonthSection] {
        let grouped = Dictionary(grouping: filteredMemories) {
            Calendar.app.dateInterval(of: .month, for: $0.date)?.start ?? $0.date
        }
        return grouped
            .map { MonthSection(month: $0.key, memories: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.month > $1.month }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    PageHeader(title: "Memories", onAdd: onAdd)

                    SearchField(text: $searchText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SelectableChip(title: "All", isSelected: selectedCategory == nil) {
                                withAnimation(.snappy) { selectedCategory = nil }
                            }
                            ForEach(store.categories.prefix(8), id: \.self) { category in
                                SelectableChip(title: category, isSelected: selectedCategory == category) {
                                    withAnimation(.snappy) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            }
                        }
                    }
                    .scrollClipDisabled()

                    LayoutToggle(layout: $layout)

                    if sections.isEmpty {
                        ContentUnavailableView(
                            "No memories found",
                            systemImage: "magnifyingglass",
                            description: Text("Try another place, tag, or moment.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(sections) { section in
                            monthSection(section)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Theme.background)
            .scrollDismissesKeyboard(.immediately)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MemoryModel.self) { memory in
                DetailMemoryPage(memory: memory)
            }
            .sheet(item: $editingMemory) { memory in
                AddMemoryPage(editing: memory)
            }
        }
    }

    private func monthSection(_ section: MonthSection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.month.monthYear())
                    .font(.serif(20))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("\(section.memories.count) \(section.memories.count == 1 ? "memory" : "memories")")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 4)

            switch layout {
            case .grid:
                MasonryGrid(memories: section.memories) { memory, ratio in
                    memoryLink(memory) {
                        MemoryGridTile(memory: memory, ratio: ratio)
                    }
                }
            case .timeline:
                ForEach(section.memories) { memory in
                    memoryLink(memory) {
                        MemoryPhotoCard(memory: memory)
                    }
                }
            }
        }
    }

    private func memoryLink<Label: View>(_ memory: MemoryModel, @ViewBuilder label: () -> Label) -> some View {
        NavigationLink(value: memory, label: label)
            .buttonStyle(.plain)
            .contextMenu {
                Button("Edit", systemImage: "pencil") {
                    editingMemory = memory
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    withAnimation { store.delete(memory) }
                }
            }
    }
}

enum MemoriesLayout: String, CaseIterable {
    case grid = "Grid"
    case timeline = "Timeline"

    var systemImage: String {
        switch self {
        case .grid: "square.grid.2x2"
        case .timeline: "rectangle.grid.1x2"
        }
    }
}

/// Pill segmented control in the journal style.
private struct LayoutToggle: View {
    @Binding var layout: MemoriesLayout

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MemoriesLayout.allCases, id: \.self) { option in
                let isSelected = option == layout
                Button {
                    withAnimation(.snappy) { layout = option }
                } label: {
                    Label(option.rawValue, systemImage: option.systemImage)
                        .labelStyle(CompactLabelStyle())
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Theme.background : Theme.ink)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 36)
                        .background(isSelected ? Theme.ink : Color.clear, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Theme.field, in: Capsule())
    }
}

private struct MonthSection: Identifiable {
    let month: Date
    let memories: [MemoryModel]
    var id: Date { month }
}

private struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.muted)
            TextField("Search places, tags, moments", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundStyle(Theme.ink)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.muted)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Theme.field, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    MemoriesListPage(onAdd: {})
        .environment(MemoryStore())
}
