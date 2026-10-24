//
//  AnnouncementCell.swift
//  CampusCompanion
//

import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        locationLabel.font = .preferredFont(forTextStyle: .subheadline)
        priorityLabel.font = .preferredFont(forTextStyle: .subheadline)
        for label in [titleLabel, dateLabel, locationLabel, priorityLabel] {
            label?.numberOfLines = 0
            label?.adjustsFontForContentSizeCategory = true
        }
        accessoryType = .disclosureIndicator
    }

    func configure(with announcement: CampusAnnouncement) {
        let title = announcement.title ?? ""
        let category = announcement.category ?? ""
        let date = announcement.date ?? ""
        let location = announcement.location ?? "Not specified"
        let priority = announcement.priority ?? "Normal"
        let isUrgent = ["urgent", "high", "critical"].contains(priority.lowercased())

        titleLabel.text = title
        dateLabel.text = "\(category) • \(date)"
        locationLabel.text = "Location: \(location.isEmpty ? "Not specified" : location)"
        priorityLabel.text = "Priority Level: \(priority)"

        // Always reset every visual property so reused cells keep the correct styling.
        categoryIconImageView.image = UIImage(systemName:
            isUrgent ? "exclamationmark.circle.fill" : "megaphone.fill")
        categoryIconImageView.tintColor = isUrgent ? .systemRed : .systemBlue
        titleLabel.textColor = isUrgent ? .systemRed : .label
        dateLabel.textColor = .secondaryLabel
        locationLabel.textColor = .secondaryLabel
        priorityLabel.textColor = isUrgent ? .systemRed : .secondaryLabel
        contentView.backgroundColor = isUrgent
            ? UIColor.systemRed.withAlphaComponent(0.08) : .clear
    }
}
