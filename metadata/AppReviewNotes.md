# Notes for App Review — Ridgeline

Ridgeline helps hikers and ascent-focused outdoor enthusiasts manually document completed outings and understand their own activity history. It is an offline journal; it is not a live navigation, location tracking, mapping, medical, or fitness sensor app.

## What the Reviewer Can Do

All functionality is available without credentials. The app has no registration, login, account, paywall, subscription, or in-app purchase.

Begin with the first-ascent onboarding flow, then:

1. Enter an ascent date, distance, elevation gain, and duration.
2. Add route details, gear, and a note, then save the ascent.
3. Return to the dashboard and inspect the generated ridge profile.
4. Open the analytics views for elevation gain, pace/grade, activity distribution, and records.
5. Visit Insights to review summaries derived from saved ascents.
6. Use History to open the ascent, edit a field, and save the change.
7. Delete the ascent from its detail or history flow.

No GPS permission, HealthKit access, map interaction, or GPX import is expected because Ridgeline does not provide those features.

## Local Persistence

Ascent details, route text, gear, and notes are private local records persisted through Core Data. UserDefaults stores app preferences and onboarding state. Nothing is sent to a server, synced to a cloud service, or collected for analytics.

## Advertising

Ridgeline contains no ads and has no advertising monetization. It does not include ad attribution, behavioral analytics, or tracking.

## Software Components

There are no third-party SDKs. The app is implemented with Apple system frameworks, including SwiftUI, Core Data, UserDefaults, and Charts.

## Why This App Is Distinct

The product is built around a manual ascent record rather than generic exercise tracking. Its dashboard transforms entered elevation data into a custom ridge profile; dedicated gain, pace/grade, distribution, and records views interpret the journal over time. The dark topographic interface and parallax treatment are original presentation work created for Ridgeline's ascent-focused workflow.

We invite the team to continue reviewing the app and are available if further details would be useful.
