# Campus Companion — Exercise 5

UIKit / storyboard app with on-demand REST fetching, Codable decoding, Core Data storage, and the Location / Priority Level coding challenge. Existing welcome preferences, event details, local add, swipe-to-delete, and announcement detail navigation are retained.

## Open and run

1. Extract the ZIP fully. Open `CampusCompanion.xcodeproj` in Xcode on your Mac.
2. Select the **CampusCompanion** scheme and an iPhone Simulator (iOS 15 or later).
3. Press **Command+B** to build, then **Command+R** to run. No packages or API keys are required.
4. Open **Campus Announcements**. This initially reads the local store without making a request.
5. Tap the circular-arrow **Refresh** button next to **+**. Dismiss the **Server Reached** alert to inspect the updated rows.
6. Open the Xcode debug console with **Shift+Command+Y** to see the byte count, actual raw JSON, decoded item count, or a diagnostic if the request fails.

For a real iPhone, select your own signing team in Signing & Capabilities. Simulator runs do not require a personal device signing setup.

## Feed

The exact supplied endpoint is defined only once, in `RemoteEndpoint.announcements`:

```
https://raw.githubusercontent.com/vonn-dev/campus-companion-api/refs/heads/main/announcements.json
```

The feed must return a top-level JSON array. Each object requires string `title`, `date`, and `category` values. `location`, `priority`, `priorityLevel`, and `postedBy` are optional string fields. Either `priority` or `priorityLevel` supplies the displayed Priority Level, with `priorityLevel` taking precedence. Missing locations display **Not specified**; missing priority uses the existing **Normal** default. The client cannot add missing fields to a remote GitHub repository. If the real feed omits Location or Priority Level, its owner must add them for real server values to appear.

This example documents the supported structure; it is not a copy of the live response:

```json
[
  {
    "title": "Campus Fair",
    "date": "October 24, 2026",
    "category": "Student Affairs",
    "location": "Main Auditorium",
    "priority": "High",
    "postedBy": "Student Affairs Office"
  }
]
```

## Organization

| Folder / file | Purpose |
| --- | --- |
| `CampusCompanion/App/` | Existing app lifecycle and Core Data stack |
| `CampusCompanion/Controllers/` | Welcome, announcements, and detail screens |
| `CampusCompanion/Models/AnnouncementDTO.swift` | Separate Codable network object |
| `CampusCompanion/Models/CampusCompanion.xcdatamodeld/` | Original M4 model and current V5 model |
| `CampusCompanion/Views/AnnouncementCell.swift` | Wrapping, aligned announcement rows |
| `CampusCompanion/Base.lproj/Main.storyboard` | Screens, Refresh action, outlets, layout constraints |
| `Submission/Reflection.txt` | Four-sentence reflection for review |
| `Submission/Verification_and_Screenshots.md` | Run checklist and required screenshot instructions |

## Request → decode → persist → display

Refresh starts one asynchronous `URLSession.shared.dataTask` and calls `resume()`. The handler checks transport error, HTTP 200–299, and non-nil data in that order, then prints the actual UTF-8 JSON. `JSONDecoder` decodes `[AnnouncementDTO]` inside `do/catch`. `DispatchQueue.main.async` moves persistence and UIKit work to the main queue. `replaceAnnouncements(with:)` deletes existing records, copies every DTO field, saves once, calls the original `loadAnnouncements()`, and reloads the table. Only a successful save produces the **Server Reached** alert with `data.count`.

The button is disabled while a request is pending and restored on every exit. Requests bypass the local response cache and time out after 30 seconds. Offline, HTTP, or decoding failures print diagnostics and leave the existing rows untouched; a save failure rolls back the replacement. A successful empty feed remains empty on relaunch instead of restoring the seed data.

**Refresh replaces the entire local announcement collection, including local additions**, as required by the lab. Repeated refreshes do not append duplicates.

## Challenge fields and layout

- Location is added to the V5 Core Data model with a migration default. The original model is preserved and the current model is selected in both Xcode and `.xccurrentversion`.
- Priority Level uses the existing Core Data `priority` attribute from M4, preserving previous priorities.
- Both fields are copied during synchronization and shown in the list and detail view.
- Announcement rows use a vertical stack, consistent 16-point outer spacing, aligned text, multiline labels, Dynamic Type, and automatic row heights.
- Urgent, High, and Critical priorities use red text/icon treatment as well as a written level.
- The centered welcome heading and form are retained inside a scroll view for smaller screens.

## Validation limits

The delivered files were checked structurally for XML/plist validity, storyboard connections, source membership, model selection, and archive integrity. This workspace does not provide Xcode, an Apple SDK, or an iOS Simulator, so a full build, runtime layout review, migration test, and authentic submission screenshots must be completed on your Mac. The live GitHub response was blocked by this environment, so its exact current schema, item count, and byte count could not be verified. No screenshots or live results have been fabricated.
