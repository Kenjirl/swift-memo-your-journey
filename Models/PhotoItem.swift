//
//  PhotoItem.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 15/11/26.
//

import UIKit

struct PhotoItem: Identifiable {
    let id = UUID()
    let data: Data
    let image: UIImage

    /// Longest side kept for stored photos.
    private static let maxSide: CGFloat = 1600

    init?(data: Data) {
        guard let original = UIImage(data: data) else { return nil }
        let longest = max(original.size.width, original.size.height)
        let scale = min(1, Self.maxSide / longest)
        let resized: UIImage
        if scale < 1 {
            let size = CGSize(width: original.size.width * scale, height: original.size.height * scale)
            resized = original.preparingThumbnail(of: size) ?? original
        } else {
            resized = original
        }
        self.image = resized
        self.data = resized.jpegData(compressionQuality: 0.85) ?? data
    }
}

/// Decoded photos keyed by memory and index, so lists don't decode on every redraw.
enum PhotoCache {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(for data: Data, key: String) -> UIImage? {
        if let cached = cache.object(forKey: key as NSString) { return cached }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: key as NSString)
        return image
    }

    /// Called after a memory's photos change, since keys are memory id + index.
    static func removeAll() {
        cache.removeAllObjects()
    }
}
