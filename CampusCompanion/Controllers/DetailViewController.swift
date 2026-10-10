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
            title = announcement.category
            messageLabel.text = """
            \(announcement.title)

            Category: \(announcement.category)
            Date: \(announcement.date)
            Priority: \(announcement.priority)
            Posted by: \(announcement.postedBy)
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
