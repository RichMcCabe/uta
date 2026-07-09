# UTA MASTER PLAN

## Project Name
**UTA — Ultimate Travel App**

## Core Vision
UTA is a comprehensive travel planning and trip execution app. It is not just a road-trip app and not just a document vault. It should help users plan, store, track, and review trips in one safe, organized place.

The guiding principle:

> Everything is optional, but everything works together.

A user may only want drive-time planning. Another may want documents, notes, expenses, fuel tracking, reservations, and trip history. UTA should scale from simple to powerful without overwhelming the user.

---

## Immediate Goal
Build a polished working app for the Orlando trip within 3 days, then refine before departure in 8–8.5 days.

This first version should be a focused **Orlando Mission Control** app:

- Hardcoded Orlando trip data
- Cool, polished UI
- Runs on phone
- No login
- No Supabase
- No external API dependency
- No maps API dependency
- No live GPS requirement initially
- Manual checkpoint tracking first

---

## Short-Term Orlando v1 Features

### 1. Mission Control Dashboard
Large card-based home screen showing:

- Trip name: Waxhaw to Orlando
- Main reservation: Titanic Exhibition at 11:00 AM
- Planned arrival
- Current projected arrival
- Buffer before reservation
- Ahead / behind status
- Next route checkpoint
- Next planned stop
- Current driver
- Next eligible driver
- Sunrise / sunset driver restriction status

### 2. Route / Checkpoint Tracker
A route screen based on the user's Excel planning approach:

- Turn-by-turn / segment-based route rows
- Segment distance
- Posted speed limit
- Legal ETA based on speed limit
- Planned ETA based on selected driver planning profile
- Planned time at each checkpoint
- Actual time passed
- Difference versus plan
- Revised ETA after each actual checkpoint entry

Initial implementation can use manual taps or manual time entry rather than GPS.

### 3. Driver Planning
Trip planning should ask:

> Any other expected drivers?

If no, skip driver setup.

If yes, select/add drivers and define whether any have driving restrictions.

### 4. Driver Restrictions
Restrictions are optional and should be controlled by a simple yes/no toggle.

Most drivers will select:

> Restrictions? No

Only if yes, show restriction fields.

Restrictions should support both sides of the clock:

- Cannot drive before sunrise
- Cannot drive after sunset / legal cutoff
- Maximum continuous driving time
- Other future restrictions

For the Orlando trip:

- Kenzie is a restricted learner driver
- She cannot drive before sunrise
- She cannot drive after sunset
- Target driving segment: about 2 hours

### 5. Driving Style / Planning Speed Adjustment
Driving style is separate from restrictions.

Restrictions = legal/safety eligibility rules.  
Driving style = planning assumption for ETA calculations.

Suggested options:

- Typically 1–5 mph below the posted speed limit
- Posted speed limit
- Typically 1–5 mph above the posted speed limit
- Typically 6–10 mph above the posted speed limit
- Custom

If anything above the posted limit is selected, display a clear warning:

> Driving above the posted speed limit is illegal. UTA does not recommend or encourage speeding. Travel time estimates are for planning only. Always obey posted speed limits, traffic laws, weather conditions, road conditions, and police instructions.

For custom values, show a stronger warning about increased stopping distance, reduced reaction time, greater crash severity, legal penalties, insurance consequences, and the fact that small speed increases often save less time than expected.

UTA should never say “drive X mph.”  
It should say “estimated travel time using your selected planning profile.”

### 6. ETA Types
UTA should eventually display multiple ETA types:

- **Legal ETA** — calculated at posted speed limits
- **Planned ETA** — based on selected planning speed profile and assigned drivers
- **Current ETA** — updated based on actual checkpoint progress and stops

### 7. Stops
Support planned and actual timing for:

- Breakfast
- Fuel
- Bathroom
- Stretch break
- Driver swap
- Other

Stops should affect revised ETA.

### 8. Reservations / Itinerary
For Orlando v1:

- Titanic Exhibition — 11:00 AM
- Bubba Gump dinner
- Jurassic escape room — 7:00 PM

Future itinerary items should support:

- Attraction
- Restaurant
- Hotel
- Flight
- Rental car
- Parking
- Event
- Other

---

## Long-Term Product Vision
UTA should become a modular travel platform.

When creating a trip, the user should enable only the modules they want.

Possible modules:

- Road Trip
- Itinerary
- Documents
- Notes
- Fuel
- Expenses
- Packing
- Reservations
- Family / shared trip
- Live Travel Mode
- Trip Memory / post-trip summary

Unused modules should stay hidden.

---

## Profiles
Use **Profile**, not “Driver Profile,” because UTA is broader than driving.

Profile may eventually include:

- Name
- Home location
- Travel preferences
- Driving capability
- Driving restrictions, only if applicable
- Planning speed style
- Food preferences
- Mobility/accessibility notes
- Emergency contact

A person is a traveler first. Driving is only one possible capability.

---

## Documents
UTA should provide a safe, secure, organized place to store important trip information:

- Uploaded documents
- Emails or copied email details
- Typed notes
- Confirmation numbers
- Tickets
- Rental agreements
- VRBO / Airbnb / hotel agreements
- Insurance documents
- Other travel records

Documents should be saved by type/category, not dumped into one folder.

### Suggested Document Categories

#### Transportation
- Flight
- Boarding pass
- Train
- Bus
- Rental car
- Ferry
- Taxi / rideshare
- Parking
- Other

#### Accommodation
- Hotel
- Airbnb
- VRBO
- Timeshare
- Campground
- Marina
- Other

#### Activities
- Attraction ticket
- Sporting event
- Concert
- Theme park
- Museum
- Guided tour
- Restaurant reservation
- Golf tee time
- Fishing charter
- Boat rental
- Other

#### Legal & Insurance
- Travel insurance
- Vehicle insurance
- Passport
- Visa
- Driver's license
- Medical document
- Other

#### Financial
- Receipt
- Invoice
- Toll pass
- Deposit confirmation
- Rental agreement
- Other

#### Miscellaneous
- Notes
- Photos
- Maps
- Emergency contacts
- Other

### Other Document Type Behavior
Every category should include **Other**.

If a user selects Other, ask:

> What type of document is this?

Example:

> Boat Rental Agreement

The app should save that custom type for the user and optionally route anonymized metadata back to the app creator for future feature planning.

Only metadata should ever be sent, never the document itself:

- Feature area: Documents
- Category: Activities
- Custom type: Boat Rental Agreement
- App version

Do not send:

- Document contents
- File names
- Reservation numbers
- Addresses
- Personal data

Suggested permission prompt:

> Help improve UTA? Send this document type anonymously so we can consider adding it to a future release.

---

## Expenses and Fuel
Expenses are optional.

Fuel tracking should be more than simple cost tracking. The user likes the idea of knowing how much gas was used for a completed journey or segment to understand fuel economy.

Fuel entry fields:

- Date/time
- Location
- Gallons
- Price per gallon
- Total cost
- Odometer
- Fuel remaining before fill
- Notes

UTA should calculate:

- MPG for the tank / segment
- Average MPG for the trip
- Fuel cost
- Fuel cost per mile
- Total gallons
- Cost by trip segment

Post-trip statistics could show:

- Total distance
- Fuel used
- Average MPG
- Fuel cost
- Average cost per gallon
- Cost per mile

---

## Trip History / Memory
Trips should be preserved as history rather than deleted by default.

A completed trip becomes a travel record containing:

- Route
- Timelines
- Documents
- Notes
- Fuel
- Expenses
- Reservations
- Photos later
- Statistics

This can eventually become a travel journal / memory book.

---

## Key Design Principles

### 1. Everything is optional, but everything works together
A simple road-trip user should not see document vault complexity. A power user can enable everything.

### 2. Common path fast, advanced path expandable
Most users should complete setup quickly. Advanced settings appear only when relevant.

### 3. Every list needs an Other option
The app should never block a user because the developer forgot an option.

### 4. UTA learns from Other values
Repeated custom values should inform future built-in options.

### 5. UTA estimates, it does not instruct unsafe behavior
The app must not encourage speeding or unsafe driving. Speed profiles are planning assumptions only.

### 6. Manual first, automation later
For v1, manual checkpoints are acceptable. GPS, APIs, imports, and AI can come later.

### 7. Build for this trip, structure for the future
The Orlando app is the first real use case, but the architecture should support broader travel planning later.

---

## Proposed Flutter Architecture

Initial folder structure:

```text
lib/
  main.dart
  data/
    orlando_trip_data.dart
  models/
    profile.dart
    trip.dart
    trip_module.dart
    route_segment.dart
    trip_stop.dart
    reservation.dart
    travel_document.dart
    fuel_entry.dart
    driver_restriction.dart
    driving_style.dart
  services/
    eta_calculator.dart
    trip_progress_service.dart
    driver_eligibility_service.dart
    fuel_calculator.dart
  screens/
    mission_control_screen.dart
    route_tracker_screen.dart
    timeline_screen.dart
    reservations_screen.dart
    documents_screen.dart
    fuel_screen.dart
    profile_screen.dart
  widgets/
    uta_card.dart
    status_tile.dart
    checkpoint_tile.dart
    reservation_card.dart
    warning_banner.dart
    section_header.dart
  theme/
    uta_theme.dart
  utils/
    time_formatters.dart
    duration_formatters.dart
```

For the first phone-ready version, not every file must be implemented immediately. We can start with `main.dart` plus a compact set of models/data, then split files as soon as the shell is stable.

---

## Orlando v1 Build Strategy

Because there are only 8–8.5 days until departure and UGA beta feedback also needs attention, the build strategy is tactical:

### Day 1
- Finish Flutter project creation
- Add this master plan to repo
- Build polished app shell
- Add Mission Control screen
- Add bottom navigation

### Day 2
- Add Orlando route data
- Add checkpoint tracker
- Add planned vs actual timing
- Add ETA recalculation basics

### Day 3
- Add itinerary/reservations
- Add driver restriction display for Kenzie
- Add stop tracking
- Improve visual polish
- Run on phone

### Days 4–8
- Refine based on testing
- Add fuel tracking if time allows
- Add documents/notes if time allows
- Fix bugs
- Prepare actual trip data

---

## Known Current Constraint
Flutter project creation is currently running on a work network and has been stuck on dependency resolution for a long time. This is likely due to work firewall/proxy/throttling while Flutter runs `flutter pub get` against pub.dev.

If it does not complete at work, rerun at home on home Wi-Fi.

Command:

```bash
flutter create .
```

Run from:

```text
C:\UTA
```

