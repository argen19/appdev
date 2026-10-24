//
//  DetailViewController.swift
//  CampusCompanion
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!

    // MARK: - Exercise 2: values passed from the welcome screen
    var studentName: String = ""
    var notificationsEnabled: Bool = false
    var selectedRole: String = ""
    var eventDate: Date = Date()
    var guestCount: Int = 1

    // MARK: - Exercise 3: announcement passed from the announcements list
    var announcement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        if let announcement = announcement {
            // Core Data generates String? properties, so unwrap each with a safe default.
            let announcementTitle = announcement.title ?? ""
            let category = announcement.category ?? ""
            let date = announcement.date ?? ""
            let priority = announcement.priority ?? "Normal"
            let location = announcement.location ?? "Not specified"
            let postedBy = announcement.postedBy ?? ""

            title = category
            messageLabel.text = """
            \(announcementTitle)

            Category: \(category)
            Date: \(date)
            Location: \(location.isEmpty ? "Not specified" : location)
            Priority Level: \(priority)
            Posted by: \(postedBy)
            """
        } else {
            title = "Campus Events"
            let notificationStatus = notificationsEnabled ? "on" : "off"

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none

            messageLabel.text = """
            Welcome, \(studentName)! (\(selectedRole))
            Notifications: \(notificationStatus).
            Event: \(formatter.string(from: eventDate))
            Guests: \(guestCount)
            """
        }
    }
}
