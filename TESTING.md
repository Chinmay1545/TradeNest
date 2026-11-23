# TradeNest — Phase 2 Test Checklist

Run this before submitting. Use two simulators (or simulator + device) signed in as two accounts, **A** (seller) and **B** (buyer).
Set a location first: Simulator → Features → Location → Apple (or a Custom Location near campus).

## Setup
- [ ] `TradeNest/GoogleService-Info.plist` exists (next to `MyApp.swift`). It's git-ignored; the app crashes on launch without it.
- [ ] Project builds with no errors (Product → Build). Ideally also try it on a machine with **Xcode 16**.

## 1. Accounts (Firebase Auth)
- [ ] Create account A and account B with made-up `.edu` emails.
- [ ] Quit and relaunch: you stay logged in. Log Out returns to the login screen.

## 2. ISBN lookup (Web API + JSON)
- [ ] A → Sell → ISBN `978-0262046305` → Look Up: title, authors and cover fill in, "Filled from Open Library" shows.
- [ ] ISBN `12345` → "Enter a 10 or 13 digit ISBN."
- [ ] Add a price, Post Listing: form clears, "Listing posted" alert. The Post button is fully visible (not behind the tab bar).

## 3. Marketplace (Table view)
- [ ] B → Market shows A's listing with cover, condition tag, "Open to trades" tag and price.
- [ ] Category filter, search, and the ⇄ "Trades only" button all filter the list. Search with no match shows "No Results".
- [ ] Pull down to refresh works.

## 4. Offers
- [ ] B posts one listing of their own (so they have something to trade).
- [ ] B opens A's listing → Make Offer → Cash with $0 → shows "Enter a cash amount greater than $0."
- [ ] B sends a cash offer, then a trade offer (pick B's item + optional cash).
- [ ] A → Offers → Received shows both, with initials, "Trade: <item> + $…", the message, and Pending badges. Tab shows the pending count.
- [ ] Swipe left on a received offer → Reject works. Swipe on a sent offer (as B) → Withdraw works.

## 5. Accept + meetup (Map + location, no hardcoded coordinates)
- [ ] A accepts an offer → other pending offers on that listing turn Rejected → the meetup picker opens.
- [ ] Allow location: blue dot + real nearby places with distances ("0.3 mi away").
- [ ] Tapping a pin selects the row; tapping a row zooms the map. Pick a time → Confirm Meetup.
- [ ] Dismiss case: accept another offer, Cancel the picker → the row's **Meetup** link → "Schedule Meetup" brings it back.
- [ ] The listing no longer appears in B's Market (Pending).

## 6. Complete the trade
- [ ] B → Offers → Sent → View Meetup: map, distance, Directions (opens Apple Maps), date/time.
- [ ] Mark as Completed → Status: Completed.
- [ ] Both Profiles: Transaction History shows the item with Bought / Sold tag; A's listing shows Sold; stats update.

## 7. Error / empty states
- [ ] New account with nothing: Market / Offers / Profile show friendly empty messages, not blank screens.
- [ ] Location denied (delete app, reinstall, Don't Allow) → "Location access is off…" message.
- [ ] Airplane mode / no network → ISBN lookup shows an error alert instead of doing nothing.

## Rubric map
| Rubric item | Where |
|---|---|
| MVVM (20) | `Views/` → `ViewModels/` (`@MainActor ObservableObject`) → `Models/` services. Views never call services. |
| Web API + JSON (15) | `Models/BookAPIService.swift` — `URLSession` + our own `Codable` structs, no 3rd-party JSON |
| Map + location, no hardcoded lat/long (10) | `Models/LocationService.swift` (`CLLocationManager`, `MKLocalSearch`), `MeetupPickerView`, `MeetupDetailView` |
| Firebase storage (20) | `Models/FirebaseService.swift` (Auth + Firestore) |
| Table view (15) | `List` on Market, Offers, Profile, Item Detail, Meetup screens (+ swipe actions) |
| UI (10) | Loading / empty / error states, badges, covers, branding on every screen |
| AI transcript (10) | Each teammate submits their AI conversation |
