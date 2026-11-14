//
//  AddMemoryPage.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 11/03/26.
//

import SwiftUI
import PhotosUI

/// Sheet for creating a memory, or editing one when `editing` is set.
struct AddMemoryPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MemoryStore.self) private var store

    /// The memory being edited; `nil` means a new memory.
    private let editing: MemoryModel?

    @State private var title: String
    @State private var story: String
    @State private var date: Date
    @State private var location: String
    @State private var tags: [String]

    @State private var photos: [PhotoItem]
    @State private var coverID: PhotoItem.ID?

    init(editing memory: MemoryModel? = nil) {
        editing = memory
        _title = State(initialValue: memory?.title ?? "")
        _story = State(initialValue: memory?.description ?? "")
        _date = State(initialValue: memory?.date ?? Date())
        _location = State(initialValue: memory?.location ?? "")
        _tags = State(initialValue: memory?.categories ?? [])

        // Existing photos (cover first). Sample memories bring their bundled image along.
        var existing: [PhotoItem] = []
        if let memory {
            if memory.photos.isEmpty {
                if !memory.imageName.isEmpty,
                   let data = UIImage(named: memory.imageName)?.jpegData(compressionQuality: 0.9),
                   let item = PhotoItem(data: data) {
                    existing = [item]
                }
            } else {
                existing = memory.photos.compactMap(PhotoItem.init(data:))
            }
        }
        _photos = State(initialValue: existing)
        _coverID = State(initialValue: existing.first?.id)
    }

    private var isEditing: Bool { editing != nil }
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    private let maxPhotos = 10

    private var canSave: Bool { !title.trimmed.isEmpty && !isLoadingPhotos }

    private var cover: PhotoItem? {
        photos.first { $0.id == coverID } ?? photos.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    photosSection
                    detailsCard
                    section("Location", hint: "Pick a place you’ve been, or type a new one like “Japan, Kyoto”.") {
                        LocationField(text: $location, options: store.locations)
                    }
                    section("Tags", hint: nil) {
                        TokenSearchField(
                            placeholder: "Search or add a tag",
                            systemImage: "tag",
                            selection: $tags,
                            options: store.categories
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Theme.background)
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text(isEditing ? "Edit Memory" : "New Memory")
                        .font(.serif(19))
                        .foregroundStyle(Theme.ink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.bold)
                        .disabled(!canSave)
                }
            }
            .onChange(of: pickerItems) { _, items in
                loadPhotos(from: items)
            }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Photos

    @ViewBuilder
    private var photosSection: some View {
        if let cover {
            VStack(alignment: .leading, spacing: 10) {
                coverPreview(cover)
                thumbnailStrip
                Text("Tap a photo to make it the cover. Long-press for more options.")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
        } else {
            PhotosPicker(selection: $pickerItems, maxSelectionCount: maxPhotos, selectionBehavior: .ordered, matching: .images) {
                VStack(spacing: 10) {
                    if isLoadingPhotos {
                        ProgressView()
                    } else {
                        Image(systemName: "photo.stack")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 52, height: 52)
                            .background(Theme.surface, in: Circle())
                    }
                    Text("Add photos")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text("Pick up to \(maxPhotos), then choose your cover")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 188)
                .background(Theme.field, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Theme.line, style: StrokeStyle(lineWidth: 2, dash: [7, 6]))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func coverPreview(_ cover: PhotoItem) -> some View {
        Color.clear
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .overlay {
                Image(uiImage: cover.image).resizable().scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .topLeading) {
                Label("Cover", systemImage: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.accent, in: Capsule())
                    .padding(12)
            }
            .overlay(alignment: .topTrailing) {
                Text("\(photos.count) of \(maxPhotos)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.45), in: Capsule())
                    .padding(12)
            }
            .animation(.snappy, value: coverID)
            .accessibilityLabel("Cover photo")
    }

    private var thumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(photos) { photo in
                    thumbnail(photo)
                }
                if photos.count < maxPhotos {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: maxPhotos - photos.count,
                        selectionBehavior: .ordered,
                        matching: .images
                    ) {
                        Group {
                            if isLoadingPhotos {
                                ProgressView()
                            } else {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .frame(width: 72, height: 72)
                        .background(Theme.field, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Theme.line, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add more photos")
                }
            }
            .padding(.vertical, 4)
        }
        .scrollClipDisabled()
    }

    private func thumbnail(_ photo: PhotoItem) -> some View {
        let isCover = photo.id == cover?.id
        return Button {
            withAnimation(.snappy) { coverID = photo.id }
        } label: {
            Color.clear
                .frame(width: 72, height: 72)
                .overlay {
                    Image(uiImage: photo.image).resizable().scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(isCover ? Theme.accent : Color.clear, lineWidth: 3)
                }
                .overlay(alignment: .bottomLeading) {
                    if isCover {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Theme.accent, in: Circle())
                            .padding(5)
                    }
                }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Button {
                remove(photo)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(.black.opacity(0.55), in: Circle())
                    .padding(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove photo")
        }
        .contextMenu {
            Button("Make Cover", systemImage: "star") {
                withAnimation(.snappy) { coverID = photo.id }
            }
            .disabled(isCover)
            Button("Remove", systemImage: "trash", role: .destructive) {
                remove(photo)
            }
        }
        .accessibilityLabel(isCover ? "Cover photo" : "Photo")
        .accessibilityHint(isCover ? "" : "Makes this the cover")
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Title")
                TextField("Name this moment", text: $title)
                    .font(.serif(20))
                    .foregroundStyle(Theme.ink)
            }
            .padding(.vertical, 12)

            divider

            HStack {
                fieldLabel("Date")
                Spacer()
                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.vertical, 10)

            divider

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Story")
                TextField("What made this moment special?", text: $story, axis: .vertical)
                    .lineLimit(3...8)
                    .foregroundStyle(Theme.ink)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func section<Content: View>(_ title: String, hint: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel(title)
            content()
            if let hint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var divider: some View {
        Rectangle().fill(Theme.line).frame(height: 1)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(Theme.muted)
    }

    // MARK: - Actions

    private func loadPhotos(from items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        isLoadingPhotos = true
        Task {
            for item in items where photos.count < maxPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let photo = PhotoItem(data: data) {
                    withAnimation(.snappy) {
                        photos.append(photo)
                        if coverID == nil { coverID = photo.id }
                    }
                }
            }
            pickerItems = []
            isLoadingPhotos = false
        }
    }

    private func remove(_ photo: PhotoItem) {
        withAnimation(.snappy) {
            photos.removeAll { $0.id == photo.id }
            if coverID == photo.id { coverID = photos.first?.id }
        }
    }

    private func save() {
        guard canSave else { return }
        // Cover goes first; the rest keep the order they were picked in.
        var ordered = photos
        if let cover, let index = ordered.firstIndex(where: { $0.id == cover.id }) {
            ordered.insert(ordered.remove(at: index), at: 0)
        }
        let memory = MemoryModel(
            id: editing?.id ?? UUID(),
            title: title.trimmed,
            location: location.trimmed,
            description: story.trimmed,
            date: date,
            imageName: "",
            photos: ordered.map(\.data),
            categories: tags
        )
        if isEditing {
            store.update(memory)
        } else {
            store.add(memory)
        }
        dismiss()
    }
}

#Preview {
    AddMemoryPage()
        .environment(MemoryStore())
}
