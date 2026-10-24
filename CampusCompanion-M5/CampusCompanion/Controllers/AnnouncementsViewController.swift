//
//  AnnouncementsViewController.swift
//  CampusCompanion
//

import UIKit
import CoreData

// Exercise 5: keep the shared HTTPS address in one named constant.
private enum RemoteEndpoint {
    static let announcements = URL(string:
        "https://raw.githubusercontent.com/vohn-dev/campus-companion-api/refs/heads/main/announcements.json"
    )!
}

class AnnouncementsViewController: UITableViewController {

    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    private var isFetchingAnnouncements = false

    // MARK: - Exercise 4: Core Data-backed data source
    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        navigationItem.backButtonTitle = "Back"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 16)
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }

    // MARK: - Exercise 5: request -> decode -> persist -> display
    // Triggered only by Refresh; opening this screen uses the existing local store.
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        fetchAnnouncementsFromServer()
    }

    func fetchAnnouncementsFromServer() {
        guard !isFetchingAnnouncements else { return }
        isFetchingAnnouncements = true
        refreshButton.isEnabled = false

        let request = URLRequest(url: RemoteEndpoint.announcements,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30)
        let task = URLSession.shared.dataTask(
            with: request
        ) { [weak self] data, response, error in
            // Every exit restores the button on the main thread, including failures.
            defer {
                DispatchQueue.main.async {
                    self?.isFetchingAnnouncements = false
                    self?.refreshButton.isEnabled = true
                }
            }

            // Required order: transport error, HTTP success, then non-nil data.
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected server response: \(response.debugDescription)")
                return
            }
            guard let data = data else {
                print("The server returned no data.")
                return
            }

            print("Reached network handler with \(data.count) bytes.")
            // Log the actual response for the lab's console screenshot.
            if let rawJSON = String(data: data, encoding: .utf8) {
                print(rawJSON)
            }

            do {
                let decodedAnnouncements = try JSONDecoder().decode(
                    [AnnouncementDTO].self, from: data
                )
                print("Decoded \(decodedAnnouncements.count) announcements.")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // A failed save must not produce a success alert.
                    guard self.replaceAnnouncements(with: decodedAnnouncements) else { return }
                    self.showNetworkConfirmationAlert(byteCount: data.count)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

    @discardableResult
    func replaceAnnouncements(with dtos: [AnnouncementDTO]) -> Bool {
        // This method is reached on the main queue, matching viewContext's queue.
        let deleteRequest: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        do {
            let existing = try context.fetch(deleteRequest)
            for item in existing { context.delete(item) }
            for dto in dtos {
                let announcement = CampusAnnouncement(context: context)
                announcement.title = dto.title
                announcement.date = dto.date
                announcement.category = dto.category
                announcement.location = dto.location ?? "Not specified"
                announcement.priority = dto.resolvedPriority
                announcement.postedBy = dto.postedBy ?? "Not specified"
            }
            try context.save()
            // Remember even a successful empty feed so relaunch does not reseed it.
            UserDefaults.standard.set(true, forKey: "hasSynchronizedAnnouncements")
            loadAnnouncements()
            tableView.reloadData()
            return true
        } catch {
            context.rollback()
            print("Persistence error: \(error)")
            return false
        }
    }

    func showNetworkConfirmationAlert(byteCount: Int) {
        guard viewIfLoaded?.window != nil, presentedViewController == nil else { return }
        let alert = UIAlertController(
            title: "Server Reached",
            message: "Received \(byteCount) bytes from the announcements endpoint.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Core Data: seed & fetch
    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0,
              !UserDefaults.standard.bool(forKey: "hasSynchronizedAnnouncements") else { return }

        let seeds: [(title: String, date: String, category: String, priority: String, postedBy: String)] = [
            ("Enrollment Period Extended", "August 3, 2026", "Registrar",
             "Normal", "Registrar's Office"),
            ("Library Hours Extended for Finals", "August 5, 2026", "Library",
             "Normal", "University Library"),
            ("Career Fair 2026", "August 10, 2026", "Career Center",
             "Normal", "Career Center"),
            ("Student Council Elections", "August 14, 2026", "Student Affairs",
             "Normal", "Student Affairs Office"),
            ("Campus Wi-Fi Maintenance Notice", "August 16, 2026", "IT Services",
             "Urgent", "IT Services"),
            ("Intramural Sports Sign-Up", "August 20, 2026", "Athletics",
             "Normal", "Athletics Office")
        ]

        for seed in seeds {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = seed.title
            announcement.date = seed.date
            announcement.category = seed.category
            announcement.priority = seed.priority
            announcement.postedBy = seed.postedBy
        }
        try? context.save()
    }

    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let fetched = (try? context.fetch(request)) ?? []

        // "date" is stored as text ("August 3, 2026"), so a plain string sort would put
        // "August 10" before "August 3". Re-order by the real calendar date.
        announcements = fetched.sorted { first, second in
            let firstDate = calendarDate(from: first.date ?? "")
            let secondDate = calendarDate(from: second.date ?? "")
            if firstDate != secondDate { return firstDate < secondDate }
            return (first.title ?? "") < (second.title ?? "")
        }
        tableView.reloadData()
    }

    private func calendarDate(from text: String) -> Date {
        let fixedFormatter = DateFormatter()
        fixedFormatter.locale = Locale(identifier: "en_US_POSIX")
        fixedFormatter.dateFormat = "MMMM d, yyyy"
        if let date = fixedFormatter.date(from: text) { return date }

        // New announcements are stamped with the device's locale (.long style).
        let localizedFormatter = DateFormatter()
        localizedFormatter.dateStyle = .long
        localizedFormatter.timeStyle = .none
        return localizedFormatter.date(from: text) ?? .distantFuture
    }

    // MARK: - Actions
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
            newAnnouncement.priority = "Normal"
            newAnnouncement.postedBy = "Student"
            try? self.context.save()
            self.loadAnnouncements()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource
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

    // MARK: - Exercise 4, Part 3: swipe-to-delete
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let announcementToDelete = announcements[indexPath.row]
        context.delete(announcementToDelete)
        try? context.save()
        announcements.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let destination = segue.destination as? DetailViewController,
              let announcement = selectedAnnouncement else { return }
        destination.announcement = announcement
    }
}
