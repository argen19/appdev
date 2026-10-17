import UIKit

private enum DefaultsKey {
    static let studentName = "studentName"
    static let notificationsEnabled = "notificationsEnabled"
    static let selectedRoleIndex = "selectedRoleIndex"
}

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var guestsStepper: UIStepper!
    @IBOutlet weak var guestsCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Campus Companion"
        subtitleLabel.text = "Your Campus, In Your Pocket"
        eventDatePicker.minimumDate = Date()
        guestsCountLabel.text = "\(Int(guestsStepper.value))"

        nameTextField.text = UserDefaults.standard.string(forKey: DefaultsKey.studentName) ?? ""
        notifySwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKey.notificationsEnabled)
        roleSegmentedControl.selectedSegmentIndex =
            UserDefaults.standard.integer(forKey: DefaultsKey.selectedRoleIndex)
    }

    @IBAction func exploreButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        let enteredName = nameTextField.text ?? ""

        UserDefaults.standard.set(enteredName, forKey: DefaultsKey.studentName)
        UserDefaults.standard.set(notifySwitch.isOn, forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.set(roleSegmentedControl.selectedSegmentIndex,
                                  forKey: DefaultsKey.selectedRoleIndex)

        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    @IBAction func guestsStepperChanged(_ sender: UIStepper) {
        guestsCountLabel.text = "\(Int(sender.value))"
    }

    @IBAction func resetPreferencesTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        UserDefaults.standard.removeObject(forKey: DefaultsKey.studentName)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.selectedRoleIndex)
        nameTextField.text = ""
        notifySwitch.isOn = false
        roleSegmentedControl.selectedSegmentIndex = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
