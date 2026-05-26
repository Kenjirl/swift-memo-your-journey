//
//  MemoryModel.swift
//  Memo Your Journey
//
//  Created by Benedict Kenjiro Lehot on 12/03/26.
//

import Foundation

struct MemoryModel: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let description: String
    let date: Date
    let imageName: String
    let categories: [String]
}
