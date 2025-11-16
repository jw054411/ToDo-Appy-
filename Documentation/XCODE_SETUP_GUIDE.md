# Xcode Setup Guide for ToDo-Appy

This guide walks through creating the Xcode project and integrating the foundation code created by Agent 1.

---

## Prerequisites

- **macOS:** 14.0 (Sonoma) or later
- **Xcode:** 15.0 or later
- **Apple Developer Account:** Free or paid (for CloudKit)

---

## Step 1: Create Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **Multiplatform → App**
4. Configure project:
   - **Product Name:** `ToDo-Appy`
   - **Team:** Select your team
   - **Organization Identifier:** `com.personal.todoappy`
   - **Bundle Identifier:** `com.personal.todoappy` (auto-filled)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** SwiftData
   - **Include Tests:** ✅ YES
5. Choose save location (parent directory of this repo)
6. Click **Create**

---

## Step 2: Import Source Files

1. In Finder, navigate to the cloned repo's `ToDo-Appy/` folder
2. Drag and drop these folders into your Xcode project:
   - `App/`
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Services/`
   - `DesignSystem/`
   - `Utilities/`
   - `Resources/`

3. When prompted:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets:** ToDo-Appy (iOS), ToDo-Appy (macOS)

4. Delete the default `ContentView.swift` if Xcode created one (we have our own)

---

## Step 3: Configure Info.plist

1. Select project in navigator → Select **ToDo-Appy** target
2. Go to **Info** tab
3. Right-click in the list → **Raw Keys & Values**
4. Add these keys:

| Key | Type | Value |
|-----|------|-------|
| `UIUserInterfaceStyle` | String | `Dark` |
| `NSUserNotificationsUsageDescription` | String | `ToDo-Appy needs notification permission to remind you about tasks.` |

---

## Step 4: Add Entitlements Files

### For iOS Target:

1. Select **ToDo-Appy (iOS)** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **iCloud**:
   - Check ✅ **CloudKit**
   - Click **+** under Containers
   - Enter: `iCloud.com.personal.todoappy`
   - Check ✅ to set as default
5. Add **Push Notifications**
6. Add **Background Modes**:
   - Check ✅ **Remote notifications**
   - Check ✅ **Background fetch**

7. Verify `ToDo-Appy.entitlements` was created
8. Replace with the entitlements file from repo: `ToDo-Appy/ToDo-Appy.entitlements`

### For macOS Target:

1. Select **ToDo-Appy (macOS)** target
2. Repeat steps 3-6 above
3. Additionally enable:
   - **App Sandbox** → ✅ YES
   - **Network** → ✅ Outgoing Connections (Client)
4. Replace with: `ToDo-Appy/ToDo-Appy-macOS.entitlements`

---

## Step 5: Configure Deployment Targets

1. Select project → **General** tab
2. Set **iOS Deployment Target:** 17.0
3. Select macOS target → Set **macOS Deployment Target:** 14.0

---

## Step 6: Create CloudKit Schema

### Access CloudKit Dashboard

1. Go to: https://icloud.developer.apple.com/dashboard
2. Sign in with your Apple Developer account
3. Select container: `iCloud.com.personal.todoappy`
4. Switch to **Development** environment (top right)

### Create Record Types

Follow the detailed instructions in `Documentation/CLOUDKIT_SCHEMA.md` to create:

1. **CKTask** record type (26 fields)
2. **CKCategory** record type (8 fields)
3. **CKTag** record type (6 fields)
4. **TasksZone** custom zone
5. Three subscriptions (TaskChanges, CategoryChanges, TagChanges)

**Important:** Set correct field types, indexes, and make fields queryable/sortable as specified.

---

## Step 7: Configure Signing

1. Select **ToDo-Appy (iOS)** target
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Xcode will automatically manage provisioning
5. Repeat for **ToDo-Appy (macOS)** target

---

## Step 8: Build and Run

### Test iOS:

1. Select **ToDo-Appy (iOS)** scheme
2. Choose **iPhone 15 Pro** simulator (or any iOS 17+ simulator)
3. Press **⌘R** to build and run
4. App should launch with placeholder "Foundation Ready ✓" screen

### Test macOS:

1. Select **ToDo-Appy (macOS)** scheme
2. Choose **My Mac**
3. Press **⌘R** to build and run
4. App should launch with same placeholder screen

### Verify Dark Mode:

1. System Settings → Appearance → Change to Light
2. App should stay in dark mode (forced in code)

---

## Step 9: Test CloudKit Connection

### Sign into iCloud on Simulator:

1. Open **Settings** app on simulator
2. Sign in with Apple ID (use test account or personal)
3. Enable **iCloud Drive**

### Verify CloudKit Access:

Add this temporary test code to `ContentView.swift`:

```swift
import CloudKit

.onAppear {
    let container = CKContainer(identifier: "iCloud.com.personal.todoappy")
    container.accountStatus { status, error in
        if status == .available {
            print("✅ CloudKit available!")
        } else {
            print("❌ CloudKit error: \(error?.localizedDescription ?? "unknown")")
        }
    }
}
```

Build and run → Check console for "✅ CloudKit available!"

---

## Step 10: Verify Structure

Your Xcode project navigator should look like this:

```
ToDo-Appy
├── App
│   ├── ToDoAppyApp.swift
│   └── AppDelegate.swift
├── Models
│   ├── Protocols
│   │   └── Syncable.swift
│   └── Enums
│       ├── SyncStatus.swift
│       ├── Priority.swift
│       └── RecurrenceType.swift
├── ViewModels
├── Views
│   ├── ContentView.swift
│   ├── iPhone
│   ├── iPad
│   ├── Mac
│   └── Components
├── Services
├── DesignSystem
│   └── Components
├── Utilities
│   └── Extensions
│       └── Date+Extensions.swift
└── Resources
    └── Assets.xcassets
```

---

## Troubleshooting

### "CloudKit container not found"
- Verify you created the container in CloudKit Dashboard
- Check spelling: `iCloud.com.personal.todoappy` (exact match)
- Wait 5-10 minutes after creating container (propagation delay)

### "Provisioning profile error"
- Select your team in Signing & Capabilities
- Clean build folder (⌘⇧K)
- Restart Xcode

### "No such module 'CloudKit'"
- Ensure iCloud capability is enabled
- Clean and rebuild

### "Cannot sign into iCloud on simulator"
- Use Xcode 15+ (better simulator support)
- Try different simulator (iPhone 15 Pro works well)
- Use real device for testing

### "App crashes on launch"
- Check console for errors
- Verify all files are added to correct targets
- Ensure SwiftData is available (iOS 17+, macOS 14+)

---

## Next Steps

Foundation is complete! ✅

**Agent 2** can now:
- Create `Task.swift`, `Category.swift`, `Tag.swift` models
- Implement `Syncable` protocol
- Add CloudKit conversion methods
- Build `RecurrenceEngine.swift`

**Agent 3** can prepare:
- `DataSyncService.swift` architecture
- Study CloudKit schema documentation

**Agent 4** can prepare:
- Design system color palette
- Typography scale
- Animation constants

---

## Validation Checklist

Before moving to Agent 2, verify:

- [ ] Project builds on iOS without errors
- [ ] Project builds on macOS without errors
- [ ] App runs on iOS Simulator
- [ ] App runs on Mac
- [ ] Dark mode is enforced (test by toggling system appearance)
- [ ] CloudKit container exists in dashboard
- [ ] All 3 record types created (CKTask, CKCategory, CKTag)
- [ ] TasksZone custom zone created
- [ ] All source files imported and organized
- [ ] Entitlements configured correctly
- [ ] No build warnings (ideally)

---

## Resources

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

**Foundation setup complete!** 🎉

Now hand off to **Agent 2** to build the data models.
