//
//  AnnouncementCell.swift
//  CampusCompanion
//

import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title

        // Every visual property is set in BOTH branches so a reused cell
        // never keeps the Urgent styling from a previous row.
        if announcement.priority == "Urgent" {
            dateLabel.text = "\(announcement.category) • URGENT • \(announcement.date)"
            categoryIconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
            categoryIconImageView.tintColor = .systemRed
            titleLabel.textColor = .systemRed
            dateLabel.textColor = .systemRed
            contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        } else {
            dateLabel.text = "\(announcement.category) • \(announcement.date)"
            categoryIconImageView.image = UIImage(systemName: "megaphone.fill")
            categoryIconImageView.tintColor = .systemBlue
            titleLabel.textColor = .label
            dateLabel.textColor = .secondaryLabel
            contentView.backgroundColor = .clear
        }
    }
}
