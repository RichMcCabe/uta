UTA Batch 3 - GPS Flight Deck and Live Navigation

Changed files only.

Features:
- Live speed, ETA, remaining distance, schedule delta, route progress and next maneuver.
- Route-position matching against maneuver path.
- Three-reading off-route confirmation with GPS accuracy filtering.
- Automatic OSRM rerouting from current GPS position to saved destination.
- Rerouting status, cooldown and failure fallback.
- Navigation start/end controls and automatic GPS tracking start.
- Current-driver and restriction status.
- Follow-mode map with heading marker, completed-route overlay and destination marker.
- Guaranteed destination checkpoint on newly generated OSRM routes.
- Android legacy and adaptive launcher icon resources.
- Complete iOS AppIcon set.

After copying files run:
flutter pub get
flutter analyze
