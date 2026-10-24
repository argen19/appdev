# Exercise 5 — verification and screenshots

Run these checks in Xcode on your Mac. These are instructions, not claims that Simulator tests have already passed. Review the reflection in `Reflection.txt` before submitting it.

## Build and existing features

- Build with Command+B and check the Issue Navigator for errors and warnings.
- Run on an iPhone Simulator. Try both a smaller phone and a larger phone.
- Check the centered welcome heading and aligned form. Scroll to reach all buttons; verify the name, notification switch, role, event date, and guest stepper still work.
- Check Explore Campus, saved preferences, and Reset Preferences.
- Open Campus Announcements. Check that opening it alone makes no request and presents no Server Reached alert.
- Check local add, swipe-to-delete, and row-to-detail navigation.

## Capture the four required screenshots

1. **Before refresh:** On a first installation, open Campus Announcements and capture the locally seeded list before tapping Refresh. If you already synchronized this installation, use a separate Simulator or remove only this Simulator app to get a clean first-run state; removing the app deletes its local data.
2. **Confirmation alert:** With internet available, tap the circular-arrow Refresh button. Capture the genuine Server Reached alert. Its byte count must match the console's `Reached network handler with N bytes.` line; the number is not hardcoded.
3. **Xcode console:** Open the console with Shift+Command+Y and capture the actual raw JSON response. Include the byte-count and decoded-count lines if practical.
4. **After refresh:** Dismiss the alert and capture the server-synchronized list with Location and Priority Level visible. If the feed and seed titles happen to be identical, compare the JSON and new field values. Do not change server content just to create an artificial difference.

Use Simulator's File > Save Screen or Command+S for app screenshots; use the Mac screenshot controls for Xcode's console. Include these real captures with your submission. The ZIP contains no fabricated Simulator screenshots.

## Refresh and persistence

- Compare title, date, category, location, and priority against the actual JSON in the console.
- Tap Refresh twice, dismissing each alert. The number of rows must equal the current server array count each time, without duplication.
- Tap a row: detail must show Location and Priority Level.
- Fully stop the app and relaunch. The synchronized records must still be present without another network request. Do not uninstall during this persistence check.
- If upgrading an installed M4 app, build/run V5 over that app using the same bundle identifier and verify its prior records before Refresh. This checks the versioned Core Data migration.
- Rotate the Simulator and increase its text size. Check that titles, dates, locations, and levels wrap, remain aligned, and do not overlap.

## Failure checks

- Disable the Mac's active network connections, then tap Refresh. Expect `Network error: ...`, no success alert, unchanged local rows, and the Refresh button enabled again after completion (up to 30 seconds).
- For an HTTP failure test, temporarily point the endpoint to a known missing file, run, and verify `Unexpected server response.` and unchanged local rows. Restore the supplied endpoint afterward.
- For the lab's decoding test, temporarily rename required DTO `title` to `misspelledTitle` and also change `dto.title` to `dto.misspelledTitle` so the project still compiles. Refresh, confirm `Decoding error: ...`, then revert BOTH edits and rebuild. This is a temporary experiment only.
- Real Location/Priority Level values require those fields in the server feed. A missing location shows `Not specified`; absent priority shows `Normal`. Both client fields are wired end to end.

## Before submitting

- Restore the exact supplied endpoint and DTO after experiments.
- Rebuild and run one final successful Refresh.
- Submit the updated project, four authentic screenshots, and the reviewed reflection.
