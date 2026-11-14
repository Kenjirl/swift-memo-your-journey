//
//  MemoriesCalendarPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 13/03/26.
//

import SwiftUI

struct MemoriesCalendarPage: View {
    @Environment(MemoryStore.self) private var store
    var onAdd: () -> Void

    @State private var month = Date()
    @State private var selectedDate = Date()
    @State private var didPickInitialDate = false
    @State private var editingMemory: MemoryModel?

    private var selectedMemories: [MemoryModel] {
        store.memories(on: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PageHeader(eyebrow: Date().weekdayDayMonth(), title: "Your Journey", onAdd: onAdd)

                    HStack(spacing: 8) {
                        StatPill(text: count(store.memories.count, "memory", "memories"))
                        StatPill(text: count(store.placeCount, "place", "places"))
                        StatPill(text: count(store.countryCount, "country", "countries"))
                    }

                    MonthCalendarView(month: $month, selectedDate: $selectedDate, memories: store.memories)

                    selectedDaySection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MemoryModel.self) { memory in
                DetailMemoryPage(memory: memory)
            }
            .onAppear(perform: jumpToLatestMemory)
            .sheet(item: $editingMemory) { memory in
                AddMemoryPage(editing: memory)
            }
        }
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedDate.weekdayDayMonth().uppercased())
                .font(.footnote.weight(.semibold))
                .tracking(1)
                .foregroundStyle(Theme.muted)

            if selectedMemories.isEmpty {
                EmptyDayCard(onAdd: onAdd)
            } else {
                ForEach(selectedMemories) { memory in
                    NavigationLink(value: memory) {
                        MemoryRowCard(memory: memory)
                    }
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
        }
    }

    /// Open on the most recent memory instead of an empty "today".
    private func jumpToLatestMemory() {
        guard !didPickInitialDate else { return }
        didPickInitialDate = true
        if let latest = store.memories.first {
            selectedDate = latest.date
            month = latest.date
        }
    }

    private func count(_ value: Int, _ singular: String, _ plural: String) -> String {
        "\(value) \(value == 1 ? singular : plural)"
    }
}

private struct EmptyDayCard: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Theme.accent)
            Text("No memories on this day")
                .font(.serif(18))
                .foregroundStyle(Theme.ink)
            Button("Add a memory", action: onAdd)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accentText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

/// Month grid where days with memories show their photo.
struct MonthCalendarView: View {
    @Binding var month: Date
    @Binding var selectedDate: Date
    let memories: [MemoryModel]

    private let calendar = Calendar.app
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var weekdaySymbols: [String] {
        calendar.shortStandaloneWeekdaySymbols.map { $0.uppercased() }
    }

    /// Leading `nil`s pad the first week so day 1 lands on the right weekday.
    private var days: [Date?] {
        guard
            let start = calendar.dateInterval(of: .month, for: month)?.start,
            let range = calendar.range(of: .day, in: .month, for: month)
        else { return [] }
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: leading)
            + range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(month.monthYear())
                    .font(.serif(20))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
                Spacer()
                monthButton("chevron.left", label: "Previous month", offset: -1)
                monthButton("chevron.right", label: "Next month", offset: 1)
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(Theme.muted)
                        .padding(.vertical, 4)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        Button {
                            withAnimation(.snappy) { selectedDate = date }
                        } label: {
                            DayCell(
                                date: date,
                                memory: memories.first { calendar.isDate($0.date, inSameDayAs: date) },
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                isFuture: date > Date()
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.shadow.opacity(0.06), radius: 12, y: 6)
    }

    private func monthButton(_ systemName: String, label: String, offset: Int) -> some View {
        Button {
            withAnimation(.snappy) {
                month = calendar.date(byAdding: .month, value: offset, to: month) ?? month
            }
        } label: {
            Image(systemName: systemName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: 36, height: 36)
                .background(Theme.pill.opacity(0.6), in: Circle())
        }
        .accessibilityLabel(label)
    }
}

private struct DayCell: View {
    let date: Date
    let memory: MemoryModel?
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool

    private let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)

    var body: some View {
        Group {
            if let memory {
                MemoryPhoto(memory: memory)
                    .frame(width: 40, height: 40)
                    .overlay(Color.black.opacity(0.38))
                    .overlay {
                        Text(date.dayNumber())
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .clipShape(shape)
                    .padding(3)
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Theme.accent, lineWidth: 2.5)
                        }
                    }
            } else {
                Text(date.dayNumber())
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(textColor)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Theme.accent : Color.clear, in: shape)
                    .overlay {
                        if isToday && !isSelected {
                            shape.strokeBorder(Theme.accent, lineWidth: 2)
                        }
                    }
                    .padding(3)
            }
        }
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var textColor: Color {
        if isSelected { return .white }
        if isToday { return Theme.accentText }
        return isFuture ? Theme.future : Theme.ink
    }

    private var accessibilityText: String {
        let day = date.longString()
        guard let memory else { return day }
        return "\(day), \(memory.title)"
    }
}

#Preview {
    MemoriesCalendarPage(onAdd: {})
        .environment(MemoryStore())
}
