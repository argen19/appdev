//
//  CampusAnnouncement.swift
//  CampusCompanion
//

import Foundation

struct CampusAnnouncement {
    let title: String
    let date: String
    let category: String
    let priority: String
    let postedBy: String
}

extension CampusAnnouncement {
    static let sampleAnnouncements: [CampusAnnouncement] = [
        CampusAnnouncement(title: "Enrollment Period Extended",
                           date: "August 3, 2026", category: "Registrar",
                           priority: "Normal", postedBy: "Registrar's Office"),
        CampusAnnouncement(title: "Library Hours Extended for Finals",
                           date: "August 5, 2026", category: "Library",
                           priority: "Normal", postedBy: "University Library"),
        CampusAnnouncement(title: "Career Fair 2026",
                           date: "August 10, 2026", category: "Career Center",
                           priority: "Normal", postedBy: "Career Center"),
        CampusAnnouncement(title: "Student Council Elections",
                           date: "August 14, 2026", category: "Student Affairs",
                           priority: "Normal", postedBy: "Student Affairs Office"),
        CampusAnnouncement(title: "Campus Wi-Fi Maintenance Notice",
                           date: "August 16, 2026", category: "IT Services",
                           priority: "Urgent", postedBy: "IT Services"),
        CampusAnnouncement(title: "Intramural Sports Sign-Up",
                           date: "August 20, 2026", category: "Athletics",
                           priority: "Normal", postedBy: "Athletics Office")
    ]
}
