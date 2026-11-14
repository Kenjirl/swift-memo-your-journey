//
//  LocationField.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import SwiftUI

struct LocationField: View {
    @Binding var text: String
    /// Places used before, most used first.
    let options: [String]
    var maxSuggestions = 5

    @FocusState private var isFocused: Bool

    private var query: String { text.trimmed }

    private func matches(_ option: String) -> Bool {
        option.localizedCaseInsensitiveContains(query)
    }

    private var isExisting: Bool {
        options.contains { $0.caseInsensitiveCompare(query) == .orderedSame }
    }

    private var suggestions: [String] {
        let pool = query.isEmpty ? options : options.filter(matches)
        return Array(pool.filter { $0.caseInsensitiveCompare(query) != .orderedSame }.prefix(maxSuggestions))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Theme.accent)
                TextField("Country, place", text: $text)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { isFocused = false }
                    .foregroundStyle(Theme.ink)
                if !query.isEmpty {
                    if isExisting || suggestions.isEmpty {
                        Text(isExisting ? "Saved place" : "New place")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(isExisting ? Theme.muted : Theme.accentText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.pill, in: Capsule())
                    }
                    Button {
                        text = ""
                        isFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear location")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            if isFocused && !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text(query.isEmpty ? "RECENT PLACES" : "MATCHING PLACES")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.8)
                        .foregroundStyle(Theme.muted)
                        .padding(.top, 10)
                        .padding(.bottom, 2)

                    ForEach(Array(suggestions.enumerated()), id: \.element) { index, option in
                        Button {
                            text = option
                            isFocused = false
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(Theme.muted)
                                    .frame(width: 20)
                                Text(option)
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                            }
                            .font(.subheadline)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < suggestions.count - 1 {
                            Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 30)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .background(Theme.field.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: isFocused)
        .animation(.snappy, value: suggestions)
    }
}
