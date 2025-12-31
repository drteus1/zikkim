Zikkim – Smoke-Free Companion
=============================

Goal: high-end SwiftUI iOS app that helps users quit smoking with Supabase-backed sync.

What’s here
-----------
- Folder scaffold for an MVVM SwiftUI app.
- Supabase schema SQL ready to run in Supabase SQL editor.
- SwiftUI views/view-models for onboarding, dashboard, and Supabase auth/profile sync.

Quick start
-----------
1) Open the project folder in Xcode (create a new SwiftUI iOS project named `Zikkim` and place the sources under `Zikkim/` to match this layout).
2) Add the Supabase Swift package: `https://github.com/supabase/supabase-swift.git` (latest version).
3) Set iOS deployment target to the latest stable iOS.
4) Configure bundle identifiers and capabilities as needed (Push/Notifications optional).

App structure
-------------
- `Zikkim/App`: App entry + Supabase client provider.
- `Zikkim/Models`: Data models (Profile, Craving, HealthMilestone).
- `Zikkim/ViewModels`: Auth/session + dashboard logic.
- `Zikkim/Views`: Onboarding flow, dashboard, reusable components.
- `Zikkim/Services`: Supabase client bootstrap.
- `Zikkim/Resources`: Static milestone data.

Supabase
--------
- Project URL: `https://khkdwaezhwvhlfipwzju.supabase.co`
- Publishable (anon) key: `sb_publishable_KKjOVejiQZuQfkWg8y5cDA_yEnEfBgi`
- Run `schema.sql` in the Supabase SQL editor to provision tables/policies.
- Auth flow: anonymous sign-in by default; swap to email/magic-link/SIWA as desired.

Onboarding (first launch only)
------------------------------
- 6-slide motivational walkthrough (Health, Wealth, Freedom themes) with parallax/gradient visuals.
- Final slide collects quit date/time, cigarettes per day, and price per pack.
- `@AppStorage("hasCompletedOnboarding")` gates the flow.

Dashboard
---------
- Real-time counters: time smoke-free, money saved, cigarettes avoided, life minutes regained.
- Health milestones timeline with progress bars.
- Quick “Log craving” action that writes to Supabase `cravings`.

Notes
-----
- Default assumptions: 20 cigarettes/pack, 11 minutes life regained per avoided cigarette.
- All Supabase writes are scoped to the authenticated user; RLS policies included in `schema.sql`.

