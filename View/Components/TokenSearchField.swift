//
//  TokenSearchField.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import SwiftUI

struct TokenSearchField: View {
    let placeholder: String
    let systemImage: String
    @Binding var selection: [String]
    /// Existing values to suggest, most used first.
    let options: [String]
    /// How a value is shown (e.g. "Japan, Mt. Fuji" → "Mt. Fuji, Japan").
    var display: (String) -> String = { $0 }
    var maxSuggestions = 6

    @State private var query = ""
    @FocusState private var isFocused: Bool

    private var trimmedQuery: String { query.trimmed }

    private func isSelected(_ value: String) -> Bool {
        selection.contains { $0.caseInsensitiveCompare(value) == .orderedSame }
    }

    private var suggestions: [String] {
        let available = options.filter { !isSelected($0) }
        guard !trimmedQuery.isEmpty else { return Array(available.prefix(maxSuggestions)) }
        return Array(
            available
                .filter {
                    $0.localizedCaseInsensitiveContains(trimmedQuery)
                        || display($0).localizedCaseInsensitiveContains(trimmedQuery)
                }
                .prefix(maxSuggestions)
        )
    }

    /// True when the typed text is new: not an existing option and not already picked.
    private var canCreate: Bool {
        guard !trimmedQuery.isEmpty else { return false }
        return !(options + selection).contains { $0.caseInsensitiveCompare(trimmedQuery) == .orderedSame }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !selection.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(selection, id: \.self) { value in
                        TokenChip(text: display(value), systemImage: systemImage) {
                            withAnimation(.snappy) { selection.removeAll { $0 == value } }
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.muted)
                TextField(placeholder, text: $query)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(commitQuery)
                    .foregroundStyle(Theme.ink)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            if isFocused && (!suggestions.isEmpty || canCreate) {
                suggestionList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: isFocused)
        .animation(.snappy, value: selection)
    }

    private var suggestionList: some View {
        VStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.element) { index, value in
                Button {
                    select(value)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: systemImage)
                            .foregroundStyle(Theme.muted)
                            .frame(width: 20)
                        Text(display(value))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Image(systemName: "plus")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                    }
                    .suggestionRow()
                }
                .buttonStyle(.plain)

                if index < suggestions.count - 1 || canCreate {
                    Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 30)
                }
            }

            if canCreate {
                Button {
                    select(trimmedQuery)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Theme.accent)
                            .frame(width: 20)
                        Text("Add “\(trimmedQuery)”")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accentText)
                        Spacer()
                        Text("New")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }
                    .suggestionRow()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .background(Theme.field.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func commitQuery() {
        guard !trimmedQuery.isEmpty else { return }
        if let match = options.first(where: { $0.caseInsensitiveCompare(trimmedQuery) == .orderedSame }) {
            select(match)
        } else if canCreate {
            select(trimmedQuery)
        } else if let first = suggestions.first {
            select(first)
        }
        isFocused = true
    }

    private func select(_ value: String) {
        if !isSelected(value) {
            selection.append(value)
        }
        query = ""
        isFocused = true
    }
}

private extension View {
    func suggestionRow() -> some View {
        self
            .font(.subheadline)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}
