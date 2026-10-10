//
//  ViewController.swift
//  CampusCompanion
//
//  Created by ARCE, EDZEL KIM on 9/19/26.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets (Activity 1)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: - Outlets (Exercise 2)
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!

    // MARK: - Outlets (Exercise 2, Part 3 challenge)
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var guestsStepper: UIStepper!
    @IBOutlet weak var guestsCountLabel: UILabel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure initial text matches the requirements
        titleLabel.text = "Campus Companion"
        subtitleLabel.text = "Your Campus, In Your Pocket"

        // Event dates cannot be in the past
        eventDatePicker.minimumDate = Date()
        guestsCountLabel.text = "\(Int(guestsStepper.value))"
    }

    // MARK: - Actions
    @IBAction func exploreButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    @IBAction func guestsStepperChanged(_ sender: UIStepper) {
        guestsCountLabel.text = "\(Int(sender.value))"
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Only the "Explore Campus" segue carries data. The "Campus Announcements"
        // segue has no identifier and is ignored here.
        guard segue.identifier == "ShowDetailSegue",
              let destination = segue.destination as? DetailViewController else {
            return
        }

        let enteredName = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        destination.studentName = enteredName.isEmpty ? "Student" : enteredName
        destination.notificationsEnabled = notifySwitch.isOn
        destination.selectedRole = roleSegmentedControl.selectedSegmentIndex == 0
            ? "Student" : "Faculty"
        destination.eventDate = eventDatePicker.date
        destination.guestCount = max(Int(guestsStepper.value), 1)
    }
}
