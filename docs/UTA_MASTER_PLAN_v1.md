# UTA_MASTER_PLAN_v1

**Date:** 2026-07-08

## Project Vision

UTA (Ultimate Travel App) is a premium travel planning and execution
application. It complements navigation apps by becoming the user's
travel command center before, during and after a trip.

### Core Principles

-   Premium appearance
-   Safety first
-   Fast
-   Modular architecture
-   Optional automation
-   Offline-first where practical
-   Keep `flutter analyze` clean

## Architecture

Trip - Legs - Route Segments - Checkpoints - Journey Events

Layers: - Models - Services - Widgets - Screens - Theme

## Completed

-   Mission Control
-   Trip Repository
-   Multiple Trips
-   Multi-leg journeys
-   Route Tracker
-   Timeline
-   ETA Engine
-   Journey Events
-   Fuel framework
-   Reservations framework
-   Document Vault framework
-   Profile framework
-   GPS Foundation

## Navigation

1.  Mission Control
2.  Trips
3.  New Trip
4.  Route Tracker
5.  Timeline
6.  GPS
7.  Legs
8.  Leg Builder
9.  Plans
10. Vault
11. Fuel
12. Profile

## Locked Decisions

1.  Trips contain multiple legs.
2.  Tracking always operates on the active leg.
3.  GPS auto logging is optional.
4.  Driving style is user configurable but legal limits remain clearly
    distinguished.
5.  Document storage is optional.
6.  Unknown document types are handled by an "Other" category.

## Development Standards

-   Always work from the latest uploaded `lib.zip`.
-   Return only changed files.
-   Return downloadable ZIPs.
-   Never silently rename files.
-   Preserve architecture.
-   Keep `flutter analyze` clean after every batch.

## Immediate Roadmap

-   Real GPS permissions
-   Device location
-   Live tracking
-   flutter_map integration
-   OpenStreetMap routing
-   Automatic checkpoint detection
-   Dynamic ETA recalculation
-   Local persistence
-   Offline support investigation

## Current Status

Architecture is stable.

GPS foundation is complete.

Ready for live GPS integration.
