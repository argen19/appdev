import UIKit
import CoreData

class AnnouncementsViewController: UITableViewController {

    private let seedCompletedKey = "hasSeededInitialAnnouncements"
    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }

    private func seedInitialAnnouncementsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: seedCompletedKey) else { return }

        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        guard let existingCount = try? context.count(for: request) else { return }
        guard existingCount == 0 else {
            UserDefaults.standard.set(true, forKey: seedCompletedKey)
            return
        }
        let seedAnnouncements = [
            (title: "Enrollment Period Extended",
             date: "August 3, 2026", category: "Registrar",
             priority: "Normal", postedBy: "Registrar's Office"),
            (title: "Library Hours Extended for Finals",
             date: "August 5, 2026", category: "Library",
             priority: "Normal", postedBy: "University Library"),
            (title: "Career Fair 2026",
             date: "August 10, 2026", category: "Career Center",
             priority: "Normal", postedBy: "Career Center"),
            (title: "Student Council Elections",
             date: "August 14, 2026", category: "Student Affairs",
             priority: "Normal", postedBy: "Student Affairs Office"),
            (title: "Campus Wi-Fi Maintenance Notice",
             date: "August 16, 2026", category: "IT Services",
             priority: "Urgent", postedBy: "IT Services"),
            (title: "Intramural Sports Sign-Up",
             date: "August 20, 2026", category: "Athletics",
             priority: "Normal", postedBy: "Athletics Office")
        ]

        for seed in seedAnnouncements {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = seed.title
            announcement.date = seed.date
            announcement.category = seed.category
            announcement.priority = seed.priority
            announcement.postedBy = seed.postedBy
        }
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: seedCompletedKey)
        } catch {
            context.rollback()
        }
    }

    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        announcements = (try? context.fetch(request)) ?? []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let seedDateFormatter = DateFormatter()
        seedDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        seedDateFormatter.dateFormat = "MMMM d, yyyy"

        func storedDate(_ announcement: CampusAnnouncement) -> Date {
            let dateText = announcement.date ?? ""
            return dateFormatter.date(from: dateText)
                ?? seedDateFormatter.date(from: dateText)
                ?? Date.distantPast
        }
        announcements.sort { storedDate($0) < storedDate($1) }
        tableView.reloadData()
    }

    @IBAction func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Announcement",
                                      message: "Enter a title and category.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Title" }
        alert.addTextField { textField in textField.placeholder = "Category" }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let titleText = alert?.textFields?[0].text, !titleText.isEmpty,
                  let categoryText = alert?.textFields?[1].text, !categoryText.isEmpty else { return }

            let newAnnouncement = CampusAnnouncement(context: self.context)
            newAnnouncement.title = titleText
            newAnnouncement.date = DateFormatter.localizedString(from: Date(),
                                                                 dateStyle: .long, timeStyle: .none)
            newAnnouncement.category = categoryText
            try? self.context.save()
            self.loadAnnouncements()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnnouncementCell", for: indexPath)
            as? AnnouncementCell else {
            return UITableViewCell()
        }
        cell.configure(with: announcements[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let announcement = announcements[indexPath.row]
        context.delete(announcement)

        do {
            try context.save()
            announcements.remove(at: indexPath.row)
            if selectedAnnouncement == announcement {
                selectedAnnouncement = nil
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            context.rollback()
            loadAnnouncements()
        }
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let destination = segue.destination as? DetailViewController,
              let announcement = selectedAnnouncement else { return }
        destination.announcement = announcement
    }
}
