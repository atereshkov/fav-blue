## Architecture

**Pattern:** MVVM with Clean Architecture principles.

**Layers & responsibilities:**
- **Domain**: Entities (BluetoothDevice / Favorite), use cases and repository interfaces.
- **Data**: Bluetooth scanner implementation; Favorites persistence adapter (currently in-memory).
- **Presentation**: SwiftUI Views + ViewModels (one ViewModel per screen / feature).
- **Composition Root**: Wires implementations to interfaces (single place for DI).

**Why this setup:**
- Modern stack for new iOS Apps.
- MVVM fits SwiftUI naturally (state binding - ViewModel).
- Clean separation allows swapping persistence (CoreData/SwiftData) or Bluetooth implementation with minimal UI changes.
- Composition Root keeps creation & wiring out of views.

## Decisions & trade-offs

**SwiftUI (vs UIKit)**
- Chosen for concise UI, live previews, and natural MVVM mapping.
- Trade-off: for this assignment, there's no need for some advanced UIKit-only patterns or wrappers.

**iOS target: 17**
- Most of the modern Swift/iOS APIs use iOS 17+, and keeping in mind assignment constraints, this is a balanced option.
- For production apps, recommended approach is to target the current and recent version of the OS.

**Persistence: in-memory**
- Quick to implement and easy to reason about for the task.
- Trade-off: not persistent across app relaunch; but easy to replace with CoreData / SwiftData — repository interface already designed.

**Bluetooth scanning behavior**
- Starts scanning automatically when entering Scanner screen.
- `CBCentralManagerScanOptionAllowDuplicatesKey` not enabled by default to avoid noisy UI updates and battery cost. If real-time updates are required, we can enable with debounce in UI.
- Devices are shown with Name / Identifier / RSSI.

**Splash**
- Implements a 2s splash screen showing full name (per task).
- It's currently driven by a simple timeout, but implementation allows replacing timeout with `async` preloads easily.

**Testing**
- Code is dev tested, decoupled and ready for unit testing (protocols + DI).
- No full test suite included due to time constraints, but previews and preview mocks are implemented.

## How to run

1. Open `FavBlue.xcodeproj` in Xcode.
2. Select the `FavBlue` scheme.
3. Select a physical iOS device (Bluetooth is not supported in Simulator).
4. Build & Run.

### Features Implemented

1. Splash screen (2s) with name centered.
2. Favorites screen:
  - List of saved devices (name or nickname + identifier).
  - Tap to edit/assign nickname.
  - Remove with confirmation (swipe/delete).
  - Placeholder when empty.
  - "Add New Devices" button to Scanner screen.
3. Scanner screen:
- Auto-start scanning, asks for Bluetooth permission if needed.
- Shows Name / Identifier / RSSI when available.
- Favorited devices visually distinct and with a heart icon.
- Tap on favorited device → prompt to remove; tap on new device → prompt to add (with optional nickname).
4. System Launch screen that matches splash for smooth transition.
5. Basic localization scaffolding.
6. Design package & SwiftUI previews for main views.

## Assumptions

1. In-memory persistence is acceptable for the assignment.
2. Removal from favorites is acceptable via swipe action (confirmation shown). Alternative UX (bottom sheet) would also be valid.
3. Favorites screen is a snapshot and does not update real-time with scanner (intentional for simplicity, battery saving and performance).
4. `CBCentralManagerScanOptionAllowDuplicatesKey` is not used by default (can be enabled if required with debounce used).

## Known limitations & Future Improvements

1. Replace **in-memory persistence** with CoreData / SwiftData or persist to disk.
2. Add **unit/integration** tests (ViewModel + usecases/repository mocks).
3. Improve **scanner robustness**: debounce updates, clean stale devices (that are 'offline' for X seconds), explicit start/stop controls.
4. Add more **Bluetooth permission UX** (explainers & fallback behaviors, like 'Open Settings' button to enable Bluetooth or/and permissions).
5. Add **Coordinator/Router** for more complex navigation flows.
6. Improve **error handling** around the **devices stream** (edge cases).
