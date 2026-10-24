//
//  AnnouncementDTO.swift
//  CampusCompanion
//

import Foundation

/// Network-only value type; never decode directly into a Core Data object.
struct AnnouncementDTO: Codable {
    let title: String
    let date: String
    let category: String
    let location: String?
    let priority: String?
    let priorityLevel: String?
    let postedBy: String?

    // Accept either common JSON spelling while retaining Exercise 4's priority field.
    // Optional challenge fields keep a three-field feed compatible; no location is invented.
    var resolvedPriority: String {
        let value = (priorityLevel ?? priority ?? "Normal")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Normal" : value
    }
}
