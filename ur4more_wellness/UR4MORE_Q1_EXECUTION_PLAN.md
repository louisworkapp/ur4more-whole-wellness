# UR4MORE Q1 Execution Plan
**Senior Product + Engineering Lead Analysis**  
**Generated:** January 2025  
**Based on:** Codebase analysis + Documentation review

---

## A) Repo Reality Check

### What is Implemented Now

**Core App Structure:**
- ✅ Flutter app (iOS/Android/Web) with Material Design 3
- ✅ Navigation system (named routes, bottom nav, main scaffold)
- ✅ Settings system (SharedPreferences, SettingsController, SettingsScope)
- ✅ Theme system (light/dark/system, custom tokens)
- ✅ Splash screen → Auth check → Home flow

**Screens/Routes Wired (17 routes):**
1. `/splash` → SplashScreen
2. `/` (main) → MainScaffold (bottom nav host)
3. `/authentication-screen` → AuthenticationScreen
4. `/settings` → SettingsProfileScreen
5. `/home` → HomeScreen (legacy, not used)
6. `/check-in` → DailyCheckInScreen (5-step flow)
7. `/courses` → CoursesScreen
8. `/courses/detail` → CourseDetailScreen
9. `/courses/week` → WeekLessonScreen
10. `/discipleship-courses` → DiscipleshipCoursesScreen
11. `/breath-presets` → BreathPresetsScreen
12. `/planner/morning-checkin` → MorningCheckInScreen
13. `/planner` → PlannerScreen
14. `/daily-calendar` → DailyCalendarScreen
15. `/planner/suggestions` → SuggestionsScreen
16. `/planner/calendar` → CalendarScreen
17. `/planner/commit` → CommitScreen

**MainScaffold Bottom Nav (5 tabs):**
- Home (HomeDashboard) - wellness cards, points, streaks, daily wisdom
- Body (BodyFitnessScreen) - structure exists
- Mind (MindCoachScreen) - structure exists
- Spirit (SpiritualGrowthScreen) - mode-aware, creed display
- Rewards (RewardsMarketplaceScreen) - "Coming Soon" placeholder

**Features Implemented:**
- ✅ Daily Check-In (5-step: RPE, pain, urge, coping, journal) - **mocked storage**
- ✅ Breathing exercises (4 presets: Quick Calm, HRV, Focus, Sleep)
- ✅ Planner (morning check-in, AI suggestions, calendar, commit)
- ✅ Courses (12-week discipleship, loading from JSON, progress tracking - **local only**)
- ✅ Faith mode selection (OFF/Light/Disciple/Kingdom Builder) - **inconsistent enums**
- ✅ Points system (award logic) - **mocked (Supabase mock)**
- ✅ Streaks (calculation logic) - **mocked (Supabase mock)**
- ✅ Content gateway (Python/FastAPI: quotes, scripture, devotionals endpoints)

**Services Implemented:**
- ✅ AuthService (local token storage, mock login)
- ✅ SettingsService (SharedPreferences persistence)
- ✅ PointsService (mocked Supabase operations)
- ✅ Telemetry (debug prints only - no production analytics)
- ✅ GatewayService (HTTP client for content API)
- ✅ FaithService (faith mode helpers)
- ✅ TruthService (creed, truth anchors)
- ✅ DevotionalService, ScriptureService, NotificationService

### What is Stubbed

**Backend Integration:**
- ⚠️ PointsService: Mock Supabase (`Sb.i.from('actions').insert()`, `Sb.i.rpc()`)
- ⚠️ Streaks: Mock Supabase queries (`Sb.i.from('checkins').select()`)
- ⚠️ Check-ins: Mock insert (`debugPrint('Mock checkin insert')`)
- ⚠️ Analytics: Debug prints only (`Telemetry.logEvent()` prints to console)

**Marketplace:**
- ⚠️ RewardsMarketplaceScreen: Shows "Coming Soon" placeholder
- ⚠️ Product definitions: Mock data (8 products in code)
- ⚠️ Purchase flow: Not implemented
- ⚠️ Fulfillment: Not implemented

**Onboarding:**
- ⚠️ No formal onboarding flow (just splash → auth check → home)
- ⚠️ First launch detection exists (`isFirstLaunch()`) but no onboarding UI

**Faith Mode Consent:**
- ⚠️ Light mode per-session consent exists (`askLightConsentIfNeeded`) but:
  - Not consistently applied across all features
  - Session-scoped only (resets on navigation)
  - No persistence strategy

### What is Missing

**Critical Gaps:**
1. ❌ **Backend database** (PostgreSQL/MongoDB) - no user/auth/profile endpoints
2. ❌ **Production analytics** (Firebase/Mixpanel/Amplitude integration)
3. ❌ **Canonical faith mode system** - multiple enum definitions (FaithMode vs FaithTier)
4. ❌ **Onboarding flow** - no welcome tour, faith mode explanation, consent UI
5. ❌ **Marketplace fulfillment** - no purchase flow, no Stripe integration
6. ❌ **Subscriptions** - no payment tiers, no subscription management
7. ❌ **Journal storage** - journal text not persisted (local-only in check-in state)
8. ❌ **Church partnerships** - no registration, dashboards, revenue sharing
9. ❌ **User sync** - all data local-only (no cloud sync)
10. ❌ **Conversion funnel** - invite system exists but not fully wired (rate limiting incomplete)

**Documentation Gaps:**
- ❌ No `docs/VISION.md` file (referenced but missing)
- ❌ No `docs/DECISIONS.md` file (referenced but missing)

### Mismatches Between Documentation and Codebase

**Faith Mode Inconsistency:**
- **Docs specify**: `FaithMode` enum (off, light, disciple, kingdomBuilder)
- **Code has**: Multiple enum definitions:
  - `lib/core/settings/settings_model.dart`: `FaithTier` (off, light, disciple, kingdom)
  - `lib/services/faith_service.dart`: `FaithMode` (off, light, disciple, kingdom)
  - `lib/features/shared/faith_mode.dart`: `FaithTier` (off, light, disciple, kingdom)
  - `gateway/app/services/gating.py`: String-based (`"off"`, `"light"`, etc.)
- **Impact**: Inconsistent type usage across codebase, conversion logic needed

**Consent Rules:**
- **Docs specify**: Light mode requires per-session consent, resets next session
- **Code has**: `askLightConsentIfNeeded()` exists but:
  - Not consistently called in all features (breathing has it, others don't)
  - Session-scoped but no clear "session" boundary
  - No persistence for consent state across app restarts

**Storage Strategy:**
- **Docs specify**: Local-first with optional cloud sync, journal text local-only by default
- **Code has**: All local (SharedPreferences), no cloud sync infrastructure, journal text not persisted at all

**Points/Streaks:**
- **Docs specify**: Backend database with sync
- **Code has**: Mock Supabase operations (no real backend)

---

## B) Q1 Build Plan (Execution-Ready)

### Epic 1: Canonical Faith Mode Gating + Consent Rules (End-to-End)

**Goal:** Unify faith mode system, implement consistent gating, complete consent rules for Light mode.

**Tickets:**

#### Ticket 1.1: Unify Faith Mode Enum Definitions
**Goal:** Single source of truth for faith mode enum, remove duplicates.

**Acceptance Criteria:**
- Single `FaithTier` enum in `lib/core/settings/settings_model.dart`
- All code uses `FaithTier` (remove `FaithMode` duplicates)
- Gateway uses string conversion (`faithTierToString()`)
- Type-safe conversions in services

**Key Files:**
- `lib/core/settings/settings_model.dart` (canonical enum)
- `lib/services/faith_service.dart` (update to use `FaithTier`)
- `lib/features/shared/faith_mode.dart` (delete, use canonical)
- `gateway/app/services/gating.py` (update string mapping)
- All files using `FaithMode` (search & replace)

**Dependencies:** None

**Test Plan:**
- Unit tests: Enum parsing/conversion
- Integration: Settings change → all screens update
- Gateway: String → enum conversion tests

---

#### Ticket 1.2: Implement Light Mode Per-Session Consent System
**Goal:** Complete consent system: ask per session, persist session state, reset on app restart.

**Acceptance Criteria:**
- Light mode users see consent dialog on first faith overlay request per session
- Consent stored in session state (not SharedPreferences)
- Consent resets on app restart (new session)
- `hideFaithOverlaysInMind` setting respected globally
- All features use consent system (breathing, quotes, verses, devotions)

**Key Files:**
- `lib/features/mind/faith/faith_consent.dart` (enhance)
- `lib/core/settings/settings_model.dart` (add session state)
- `lib/services/faith_service.dart` (consent helpers)
- `lib/features/breath/presentation/breath_session_screen.dart` (integrate)
- `lib/widgets/daily_inspiration_card.dart` (integrate)
- `lib/services/scripture_service.dart` (integrate)

**Dependencies:** Ticket 1.1

**Test Plan:**
- Unit: Consent dialog logic (OFF/Light/Disciple/Kingdom)
- Integration: Light mode user → consent dialog → overlay shown/hidden
- Edge cases: App restart resets consent, global toggle overrides

---

#### Ticket 1.3: Implement Faith Mode Gating Across All Features
**Goal:** Consistent faith mode gating: content filtering, UI visibility, feature access.

**Acceptance Criteria:**
- OFF mode: No faith content visible anywhere
- Light mode: Consent-required overlays
- Disciple/Kingdom: All content available
- Courses: Gated by faith tier (12-week requires Disciple+)
- Rewards: Faith products hidden in OFF mode
- Home dashboard: Spiritual Growth card hidden in OFF mode

**Key Files:**
- `lib/presentation/home_dashboard/home_dashboard.dart` (card filtering)
- `lib/features/courses/data/course_repository.dart` (tier gating)
- `lib/presentation/rewards_marketplace_screen/rewards_marketplace_screen.dart` (product filtering)
- `lib/services/gateway_service.dart` (faith mode in API calls)
- `gateway/app/services/gating.py` (server-side gating)

**Dependencies:** Tickets 1.1, 1.2

**Test Plan:**
- Unit: Gating logic for each feature
- Integration: Mode change → UI updates immediately
- E2E: OFF → Light conversion → content appears with consent

---

#### Ticket 1.4: Implement Conversion Invite System with Rate Limiting
**Goal:** Respectful invitations to upgrade faith mode with strict rate limiting.

**Acceptance Criteria:**
- Rate limit: Max 1 invite per day
- Snooze: 7 days on "Not now"
- Weekly reset: Counter resets Sundays
- Triggers: Week completion, high-urge resolved, values milestone
- Permanent opt-out: User can disable all invites
- Analytics: Track invite shown/accepted

**Key Files:**
- `lib/features/mind/presentation/widgets/meaning_horizon_card.dart` (invite UI)
- `lib/features/mind/presentation/widgets/switch_to_faith_mode_modal.dart` (upgrade modal)
- `lib/core/settings/settings_model.dart` (add invite state: `lastInviteShown`, `inviteSnoozeUntil`)
- `lib/services/faith_service.dart` (rate limiting logic)
- `lib/core/services/telemetry.dart` (invite events)

**Dependencies:** Tickets 1.1-1.3

**Test Plan:**
- Unit: Rate limiting logic (1/day, 7-day snooze, Sunday reset)
- Integration: Triggers → invite shown → user accepts/declines
- Edge cases: Multiple triggers same day (only one invite), permanent opt-out

---

### Epic 2: Onboarding v1 (Consent + Faith Mode Explanation)

**Goal:** First-time user experience: welcome tour, faith mode selection, consent explanations.

**Tickets:**

#### Ticket 2.1: Design Onboarding Flow (Product/Design)
**Goal:** Define onboarding screens, copy, and flow.

**Acceptance Criteria:**
- Welcome screen (app intro, value proposition)
- Faith mode selection screen (OFF/Light/Disciple/Kingdom with descriptions)
- Consent explanation (Light mode consent model)
- Feature tour (optional, skip-able)
- Completion → Home dashboard

**Key Files:**
- Design specs (Figma/design doc)
- Copy document (faith mode descriptions, consent explanations)

**Dependencies:** None

**Test Plan:**
- Design review: Stakeholder approval
- User testing: 5 users, clarity of faith mode options

---

#### Ticket 2.2: Implement Onboarding Screens
**Goal:** Build onboarding UI screens.

**Acceptance Criteria:**
- WelcomeScreen (intro, "Get Started" CTA)
- FaithModeSelectionScreen (4 options with descriptions, "Continue" CTA)
- ConsentExplanationScreen (Light mode consent model, "I Understand" CTA)
- FeatureTourScreen (optional, skip-able, 3-5 slides)

**Key Files:**
- `lib/presentation/onboarding/welcome_screen.dart` (new)
- `lib/presentation/onboarding/faith_mode_selection_screen.dart` (new)
- `lib/presentation/onboarding/consent_explanation_screen.dart` (new)
- `lib/presentation/onboarding/feature_tour_screen.dart` (new)
- `lib/routes/app_routes.dart` (add routes)

**Dependencies:** Ticket 2.1

**Test Plan:**
- Unit: Screen navigation, state management
- Integration: First launch → onboarding → home
- UX: Skip flow, back navigation, progress indicators

---

#### Ticket 2.3: Wire Onboarding to First Launch
**Goal:** Trigger onboarding on first app launch, persist completion.

**Acceptance Criteria:**
- First launch detection (`SettingsService.isFirstLaunch()`)
- Onboarding shown on first launch only
- Completion persisted (`onboarding_completed` flag)
- Skip option available (defaults to OFF mode)
- Returning users skip onboarding

**Key Files:**
- `lib/presentation/splash_screen/splash_screen.dart` (onboarding check)
- `lib/core/services/settings_service.dart` (add `onboarding_completed` key)
- `lib/main.dart` (onboarding route on first launch)

**Dependencies:** Tickets 2.1, 2.2

**Test Plan:**
- Unit: First launch detection, completion flag
- Integration: First launch → onboarding → home → restart → home (no onboarding)
- Edge cases: App reinstall, settings reset

---

### Epic 3: Analytics Platform Integration + Core Funnel Events

**Goal:** Production analytics (Firebase/Mixpanel), core events, conversion funnel tracking.

**Tickets:**

#### Ticket 3.1: Choose Analytics Platform + Setup
**Goal:** Select platform (Firebase/Mixpanel/Amplitude), create project, configure.

**Acceptance Criteria:**
- Platform selected (recommend Firebase for Flutter integration)
- Project created, API keys configured
- Privacy levels implemented (Standard/Strict/Opt-out)
- User properties: faith_tier, user_id, onboarding_completed

**Key Files:**
- `pubspec.yaml` (add analytics package: `firebase_analytics` or `mixpanel_flutter`)
- `lib/core/services/telemetry.dart` (refactor to use real SDK)
- `.env` or config file (API keys)

**Dependencies:** None

**Test Plan:**
- Manual: Events appear in analytics dashboard
- Unit: Privacy level filtering (Strict mode = aggregate only)

---

#### Ticket 3.2: Implement Core Funnel Events
**Goal:** Track activation, retention, conversion events.

**Acceptance Criteria:**
- Activation: `first_checkin_completed`, `first_activity_completed`
- Retention: `app_opened`, `daily_checkin_completed`, `streak_milestone`
- Conversion: `faith_mode_changed`, `invite_shown`, `invite_accepted`
- Engagement: `workout_completed`, `mind_session_completed`, `devotion_completed`

**Key Files:**
- `lib/core/services/telemetry.dart` (implement events)
- `lib/presentation/daily_check_in_screen/daily_check_in_screen.dart` (activation events)
- `lib/features/mind/presentation/widgets/switch_to_faith_mode_modal.dart` (conversion events)
- All feature screens (engagement events)

**Dependencies:** Ticket 3.1

**Test Plan:**
- Unit: Event properties, user properties
- Integration: User actions → events in dashboard
- Funnel: Activation → Retention → Conversion pipeline

---

#### Ticket 3.3: Implement Privacy Levels
**Goal:** Respect user privacy preferences (Standard/Strict/Opt-out).

**Acceptance Criteria:**
- Standard: Full event tracking with user properties
- Strict: Aggregate data only (no user IDs, no fine-grained content)
- Opt-out: Minimal tracking (essential functionality only)
- Settings UI: Privacy level selection
- Default: Standard (opt-in)

**Key Files:**
- `lib/core/settings/settings_model.dart` (add `privacyLevel`)
- `lib/core/services/telemetry.dart` (privacy filtering)
- `lib/presentation/settings_profile_screen/widgets/privacy_settings_widget.dart` (new)

**Dependencies:** Tickets 3.1, 3.2

**Test Plan:**
- Unit: Privacy filtering logic
- Integration: Strict mode → aggregate events only
- Compliance: GDPR opt-out respects privacy level

---

### Epic 4: Backend DB + User Sync (Streaks/Points/Plans/Courses)

**Goal:** PostgreSQL database, user sync, progress tracking.

**Tickets:**

#### Ticket 4.1: Database Schema Design + Migration Scripts
**Goal:** Design PostgreSQL schema, create migration scripts.

**Acceptance Criteria:**
- Schema designed (see Section C for details)
- Migration scripts (initial schema, indexes)
- Local dev setup (Docker Compose for Postgres)
- Schema documented (ERD, field descriptions)

**Key Files:**
- `database/migrations/001_initial_schema.sql` (new)
- `database/schema.sql` (new, reference schema)
- `docker-compose.yml` (add Postgres service)

**Dependencies:** None

**Test Plan:**
- Manual: Migrations run successfully
- Unit: Schema validation (constraints, indexes)

---

#### Ticket 4.2: Backend API: Auth + User Profile Endpoints
**Goal:** FastAPI endpoints for authentication and user profile management.

**Acceptance Criteria:**
- `POST /auth/login` (phone/SMS or email/password)
- `POST /auth/refresh` (JWT refresh)
- `GET /users/me` (current user profile)
- `PATCH /users/me` (update profile, settings)
- JWT authentication (kid-based rotation)

**Key Files:**
- `gateway/app/routers/auth.py` (new)
- `gateway/app/routers/users.py` (new)
- `gateway/app/services/auth.py` (enhance JWT)
- `gateway/app/models.py` (add User, Auth models)

**Dependencies:** Ticket 4.1

**Test Plan:**
- Unit: JWT generation/validation
- Integration: Login → JWT → authenticated requests
- Security: Token expiry, refresh flow

---

#### Ticket 4.3: Backend API: Check-Ins + Points + Streaks
**Goal:** Endpoints for daily check-ins, points, streaks.

**Acceptance Criteria:**
- `POST /checkins` (create check-in: RPE, pain, urge, coping, journal)
- `GET /checkins` (list user check-ins, pagination)
- `GET /users/me/points` (current points balance)
- `POST /users/me/points/award` (award points, idempotent)
- `GET /users/me/streak` (current streak, milestones)

**Key Files:**
- `gateway/app/routers/checkins.py` (new)
- `gateway/app/routers/points.py` (new)
- `gateway/app/models.py` (add CheckIn, PointsAction models)
- Database: Check-ins table, points_actions table

**Dependencies:** Tickets 4.1, 4.2

**Test Plan:**
- Unit: Points calculation, streak logic
- Integration: Check-in → points awarded → streak updated
- Edge cases: Duplicate check-ins (idempotent), negative points (floor at 0)

---

#### Ticket 4.4: Flutter: Replace Mock Services with Real API Calls
**Goal:** Update Flutter services to call backend API instead of mocks.

**Acceptance Criteria:**
- PointsService: Real HTTP calls to `/users/me/points/award`
- Streaks: Real HTTP calls to `/users/me/streak`
- Check-ins: Real HTTP calls to `/checkins`
- Error handling: Network errors, retry logic, offline fallback
- Auth: JWT token management, refresh flow

**Key Files:**
- `lib/core/services/points_service.dart` (replace mock with HTTP)
- `lib/features/home/streaks.dart` (replace mock with HTTP)
- `lib/presentation/daily_check_in_screen/daily_check_in_screen.dart` (replace mock with HTTP)
- `lib/core/services/auth_service.dart` (add JWT refresh)
- `lib/services/api_client.dart` (new, HTTP client with auth)

**Dependencies:** Tickets 4.2, 4.3

**Test Plan:**
- Unit: API client, error handling
- Integration: Check-in → API call → points updated → UI refresh
- Edge cases: Offline mode, network errors, token expiry

---

#### Ticket 4.5: Backend API: Plans + Course Progress
**Goal:** Endpoints for daily plans and course progress.

**Acceptance Criteria:**
- `GET /plans` (list user plans, date range)
- `POST /plans` (create plan: activities, commitments)
- `PATCH /plans/:id` (update plan, mark activities complete)
- `GET /courses/:id/progress` (course progress, week completion)
- `POST /courses/:id/progress` (update progress, mark week complete)

**Key Files:**
- `gateway/app/routers/plans.py` (new)
- `gateway/app/routers/courses.py` (new)
- Database: Plans table, course_progress table

**Dependencies:** Tickets 4.1, 4.2

**Test Plan:**
- Unit: Plan creation, progress calculation
- Integration: Planner → API → plan saved → progress tracked

---

#### Ticket 4.6: Flutter: Plans + Course Progress Sync
**Goal:** Update Flutter to sync plans and course progress with backend.

**Acceptance Criteria:**
- PlanRepository: Real HTTP calls to `/plans`
- CourseRepository: Real HTTP calls to `/courses/:id/progress`
- Local cache: Offline support (SharedPreferences fallback)
- Sync strategy: Local-first, sync on app open

**Key Files:**
- `lib/features/planner/data/plan_repository.dart` (replace local with HTTP)
- `lib/features/courses/data/course_repository.dart` (replace local with HTTP)
- `lib/services/sync_service.dart` (new, sync coordinator)

**Dependencies:** Tickets 4.4, 4.5

**Test Plan:**
- Unit: Sync logic, conflict resolution
- Integration: Plan created → API → sync → other devices
- Edge cases: Offline creation, sync conflicts

---

### Epic 5: Marketplace v1 (Digital Redemption First)

**Goal:** Digital product redemption (no payments yet, points-only).

**Tickets:**

#### Ticket 5.1: Backend API: Products + Redemption
**Goal:** Endpoints for products and point redemption.

**Acceptance Criteria:**
- `GET /products` (list products, filter by category, faith tier)
- `GET /products/:id` (product details)
- `POST /orders` (create order: product_id, points_cost)
- `GET /orders` (list user orders, status)
- Points deduction on redemption (idempotent)

**Key Files:**
- `gateway/app/routers/products.py` (new)
- `gateway/app/routers/orders.py` (new)
- Database: Products table, orders table

**Dependencies:** Epic 4 (points system)

**Test Plan:**
- Unit: Points deduction, order creation
- Integration: Redeem product → points deducted → order created
- Edge cases: Insufficient points, duplicate redemption (idempotent)

---

#### Ticket 5.2: Flutter: Marketplace UI (Remove "Coming Soon")
**Goal:** Replace placeholder with functional marketplace.

**Acceptance Criteria:**
- Products list (categories, search, faith tier filtering)
- Product detail modal (points cost, requirements, terms)
- Redemption flow (confirm → redeem → success)
- Order history (past redemptions)
- Points balance display (real-time)

**Key Files:**
- `lib/presentation/rewards_marketplace_screen/rewards_marketplace_screen.dart` (remove placeholder)
- `lib/presentation/rewards_marketplace_screen/widgets/product_detail_modal_widget.dart` (enhance)
- `lib/services/marketplace_service.dart` (new, API client)

**Dependencies:** Ticket 5.1

**Test Plan:**
- Unit: Product filtering, redemption logic
- Integration: Browse → Redeem → Points updated → Order created
- UX: Loading states, error handling, success feedback

---

#### Ticket 5.3: Digital Product Delivery
**Goal:** Digital product access (download links, unlock codes).

**Acceptance Criteria:**
- Digital products: Download links, unlock codes, access tokens
- Order status: `pending` → `fulfilled` (automatic for digital)
- Access screen: View redeemed digital products
- Downloads: PDFs, eBooks, music files (CDN URLs)

**Key Files:**
- `gateway/app/routers/orders.py` (fulfillment logic)
- `lib/presentation/rewards_marketplace_screen/widgets/digital_access_screen.dart` (new)
- Storage: CDN or S3 for digital assets

**Dependencies:** Tickets 5.1, 5.2

**Test Plan:**
- Unit: Fulfillment logic, access token generation
- Integration: Redeem digital → access granted → download works
- Security: Access tokens, expiration

---

### Epic 6: Payments/Subscriptions (Stripe) Foundations

**Goal:** Stripe integration, subscription tiers, payment foundations.

**Tickets:**

#### Ticket 6.1: Stripe Setup + Webhook Infrastructure
**Goal:** Stripe account, webhook endpoints, subscription products.

**Acceptance Criteria:**
- Stripe account configured, API keys (test + prod)
- Webhook endpoint: `/webhooks/stripe` (event handling)
- Subscription products created (Free, Premium tiers)
- Webhook events: `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`

**Key Files:**
- `gateway/app/routers/webhooks.py` (new)
- `gateway/app/services/stripe_service.py` (new)
- `.env` (Stripe keys)

**Dependencies:** None

**Test Plan:**
- Manual: Webhook events received, processed
- Unit: Webhook signature validation, event parsing

---

#### Ticket 6.2: Backend API: Subscriptions
**Goal:** Endpoints for subscription management.

**Acceptance Criteria:**
- `GET /users/me/subscription` (current subscription status)
- `POST /subscriptions/create-checkout` (Stripe Checkout session)
- `POST /subscriptions/cancel` (cancel subscription)
- Database: Subscriptions table (sync with Stripe)

**Key Files:**
- `gateway/app/routers/subscriptions.py` (new)
- `gateway/app/services/stripe_service.py` (subscription logic)
- Database: Subscriptions table

**Dependencies:** Tickets 4.1, 6.1

**Test Plan:**
- Unit: Subscription creation, cancellation
- Integration: Create checkout → Stripe → webhook → subscription active
- Edge cases: Failed payment, subscription expiry

---

#### Ticket 6.3: Flutter: Subscription UI (Settings)
**Goal:** Subscription management UI in settings.

**Acceptance Criteria:**
- Subscription status display (Free/Premium, expiry date)
- Upgrade button (opens Stripe Checkout)
- Cancel subscription (confirmation dialog)
- Feature gating (Premium features locked for Free users)

**Key Files:**
- `lib/presentation/settings_profile_screen/widgets/subscription_settings_widget.dart` (new)
- `lib/services/subscription_service.dart` (new, API client)
- `lib/core/settings/settings_model.dart` (add `subscriptionTier`)

**Dependencies:** Tickets 6.1, 6.2

**Test Plan:**
- Unit: Subscription status, feature gating
- Integration: Upgrade → Stripe → subscription active → features unlocked
- UX: Loading states, error handling, success feedback

---

## C) Data + API Design Draft

### Database Schema (PostgreSQL)

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    full_name VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    faith_tier VARCHAR(20) DEFAULT 'off' CHECK (faith_tier IN ('off', 'light', 'disciple', 'kingdom')),
    subscription_tier VARCHAR(20) DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
    points INTEGER DEFAULT 0 CHECK (points >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User settings (JSONB for flexibility)
CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily check-ins
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_date DATE NOT NULL,
    rpe INTEGER NOT NULL CHECK (rpe >= 1 AND rpe <= 10),
    pain BOOLEAN DEFAULT FALSE,
    urge INTEGER CHECK (urge >= 0 AND urge <= 10),
    coping_done BOOLEAN DEFAULT FALSE,
    journal_text TEXT, -- Local-only by default, opt-in for cloud
    journal_cloud_sync BOOLEAN DEFAULT FALSE, -- Consent flag
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, plan_date)
);

-- Points actions (audit trail)
CREATE TABLE points_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    value INTEGER NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily plans
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_date DATE NOT NULL,
    activities JSONB NOT NULL, -- Array of {time, type, title, completed}
    committed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, plan_date)
);

-- Course progress
CREATE TABLE course_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id VARCHAR(100) NOT NULL,
    week_number INTEGER NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, course_id, week_number)
);

-- Products (marketplace)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    points_cost INTEGER NOT NULL CHECK (points_cost >= 0),
    is_digital BOOLEAN DEFAULT FALSE,
    is_physical BOOLEAN DEFAULT FALSE,
    faith_tier_required VARCHAR(20) CHECK (faith_tier_required IN ('off', 'light', 'disciple', 'kingdom')),
    availability BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders (marketplace)
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    points_cost INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'fulfilled', 'shipped', 'cancelled')),
    fulfillment_data JSONB, -- Digital: download_url, access_token; Physical: shipping_address
    created_at TIMESTAMPTZ DEFAULT NOW(),
    fulfilled_at TIMESTAMPTZ
);

-- Subscriptions (Stripe sync)
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stripe_subscription_id VARCHAR(255) UNIQUE,
    tier VARCHAR(20) NOT NULL CHECK (tier IN ('free', 'premium')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'trialing')),
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Analytics events (privacy-respecting)
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- NULL for Strict/Opt-out
    event_type VARCHAR(100) NOT NULL,
    properties JSONB,
    privacy_level VARCHAR(20) DEFAULT 'standard' CHECK (privacy_level IN ('standard', 'strict', 'opt-out')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_checkins_user_date ON checkins(user_id, plan_date DESC);
CREATE INDEX idx_points_actions_user ON points_actions(user_id, created_at DESC);
CREATE INDEX idx_plans_user_date ON plans(user_id, plan_date DESC);
CREATE INDEX idx_course_progress_user ON course_progress(user_id, course_id);
CREATE INDEX idx_orders_user ON orders(user_id, created_at DESC);
CREATE INDEX idx_analytics_events_user ON analytics_events(user_id, created_at DESC);
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type, created_at DESC);
```

### REST API Endpoints

#### Auth
- `POST /auth/login` - Phone/SMS or email/password login
- `POST /auth/refresh` - Refresh JWT token
- `POST /auth/logout` - Logout (client-side token removal)

#### Users
- `GET /users/me` - Current user profile
- `PATCH /users/me` - Update profile (name, timezone, etc.)
- `GET /users/me/settings` - User settings
- `PATCH /users/me/settings` - Update settings (faith_tier, notifications, etc.)

#### Check-ins
- `POST /checkins` - Create check-in
- `GET /checkins` - List check-ins (pagination, date range)
- `GET /checkins/:id` - Get specific check-in

#### Points & Streaks
- `GET /users/me/points` - Current points balance
- `POST /users/me/points/award` - Award points (idempotent)
- `GET /users/me/streak` - Current streak, milestones

#### Plans
- `GET /plans` - List plans (date range)
- `POST /plans` - Create plan
- `PATCH /plans/:id` - Update plan (mark activities complete)
- `DELETE /plans/:id` - Delete plan

#### Courses
- `GET /courses/:id/progress` - Course progress
- `POST /courses/:id/progress` - Update progress (mark week complete)

#### Marketplace
- `GET /products` - List products (filters: category, faith_tier)
- `GET /products/:id` - Product details
- `POST /orders` - Create order (redeem product)
- `GET /orders` - List user orders
- `GET /orders/:id` - Order details

#### Subscriptions
- `GET /users/me/subscription` - Current subscription status
- `POST /subscriptions/create-checkout` - Create Stripe Checkout session
- `POST /subscriptions/cancel` - Cancel subscription
- `POST /webhooks/stripe` - Stripe webhook handler

### Sync Strategy: Local-First with Privacy Levels

**Local-First Approach:**
- Data stored locally (SharedPreferences, SQLite) first
- Sync to cloud on app open, background sync periodically
- Offline-first: App works without internet
- Conflict resolution: Last-write-wins (server timestamp)

**Privacy Levels:**
- **Standard**: Full sync (all data except journal_text unless `journal_cloud_sync=true`)
- **Strict**: Aggregate sync (points, streaks, progress - no user IDs in analytics)
- **Opt-out**: Minimal sync (authentication only, no data sync)

**Journal Text Rules:**
- Default: Local-only (`journal_cloud_sync=false`)
- Opt-in: User explicitly enables cloud sync in settings
- Consent: Clear explanation of cloud storage implications
- Storage: `journal_text` only synced if `journal_cloud_sync=true`

**Sync Flow:**
1. App opens → Check for pending local changes
2. If online → Sync to backend (batch updates)
3. If offline → Queue for sync, continue with local data
4. Background sync: Every 15 minutes if app in foreground
5. Conflict resolution: Server timestamp wins, merge strategy for plans

---

## D) Risk Register

### 1. Clinical Safety: Crisis Incidents
**Risk:** User in crisis (suicidal ideation, self-harm) not properly referred.

**Mitigation:**
- Crisis protocols: Always-visible Help link in Mind Coach
- Geo-aware resources: 988 (US), international hotlines
- Content review: Clinical Review Board approval for all therapeutic content
- Monitoring: Track crisis incidents per DAU, safety gating (rollback if >20% increase)

**Build Now:**
- Help link in Mind Coach (already exists)
- Crisis resource links (geo-aware)
- Safety monitoring dashboard (track incidents)

**Build Later:**
- AI detection of crisis language (if LLM added)
- Proactive outreach (requires legal review)

---

### 2. Theological Accuracy: Doctrinal Errors
**Risk:** Incorrect scripture citations, doctrinal inconsistencies.

**Mitigation:**
- KJV-only policy: All scripture KJV, ≤2 sentences
- Theology Review Board: External pastor/theologian review
- Content governance: Every PR requires theology checklist
- Version control: All content changes tracked

**Build Now:**
- Content review process (SOP exists)
- Automated KJV verse length validation (≤2 sentences)
- Content versioning (JSON version fields)

**Build Later:**
- AI-generated scripture validation (if LLM added)
- User reporting system (flag incorrect content)

---

### 3. Privacy: Journal Text Cloud Storage
**Risk:** Journal text stored in cloud without consent, GDPR violations.

**Mitigation:**
- Default local-only: `journal_cloud_sync=false` by default
- Explicit opt-in: User must enable cloud sync in settings
- Clear consent: Explanation of cloud storage implications
- Data deletion: Right to deletion (GDPR compliance)

**Build Now:**
- Local-only default (`journal_cloud_sync` flag)
- Settings UI: Cloud sync toggle with explanation
- Database: `journal_text` only synced if opt-in

**Build Later:**
- End-to-end encryption for journal text (if cloud sync enabled)
- Data export (GDPR data portability)

---

### 4. App Store: Faith Mode Rejection
**Risk:** App stores reject app due to faith content, require content filtering.

**Mitigation:**
- OFF mode: Fully useful without faith content
- Content filtering: Faith content hidden in OFF mode
- Age rating: 13+ with parental consent
- Transparent disclosure: Clear app description, faith mode explanation

**Build Now:**
- OFF mode fully functional (no faith content)
- Age gate: 13+ check on first launch
- App store description: Clear disclosure of faith integration

**Build Later:**
- Regional content filtering (if required by app stores)
- Alternative distribution (if rejected)

---

### 5. Operations: Database Scaling
**Risk:** Database performance issues as user base grows.

**Mitigation:**
- Indexes: Proper indexes on frequently queried fields
- Connection pooling: PgBouncer or similar
- Read replicas: Separate read/write databases
- Monitoring: Database performance metrics

**Build Now:**
- Database indexes (see schema)
- Connection pooling (PgBouncer)
- Basic monitoring (slow query logs)

**Build Later:**
- Read replicas (when needed)
- Database sharding (if required)

---

### 6. Payments: Stripe Webhook Failures
**Risk:** Webhook events lost, subscription state out of sync.

**Mitigation:**
- Idempotency: Webhook handlers idempotent (check Stripe event ID)
- Retry logic: Stripe retries failed webhooks
- Manual sync: Admin tool to sync subscription state
- Monitoring: Alert on webhook failures

**Build Now:**
- Idempotent webhook handlers (check event ID)
- Webhook signature validation
- Basic monitoring (webhook success/failure logs)

**Build Later:**
- Admin sync tool (if needed)
- Automated retry for failed webhooks

---

### 7. Conversion: OFF→Light Conversion Low
**Risk:** Conversion rate below 10% target, product-market fit issues.

**Mitigation:**
- A/B testing: Test different invite copy, timing
- Analytics: Track conversion funnel, identify drop-off points
- User research: Interview non-converters, understand barriers
- Iteration: Rapid iteration on conversion flow

**Build Now:**
- Analytics funnel tracking (Epic 3)
- Conversion events (invite_shown, invite_accepted)
- User research plan (interviews)

**Build Later:**
- A/B testing framework (if conversion low)
- Advanced personalization (if LLM added)

---

### 8. Content: Prohibited Terms in User-Generated Content
**Risk:** User inputs prohibited terms (yoga, chakra, etc.), brand safety violation.

**Mitigation:**
- Client-side filtering: Filter prohibited terms on input
- Server-side validation: Backend validates all user inputs
- Brand rules: Centralized banned terms list
- Monitoring: Alert on prohibited term detection

**Build Now:**
- Client-side filtering (`BrandRules.isContentSafe()`)
- Server-side validation (gateway filters)
- Banned terms list (centralized)

**Build Later:**
- AI content moderation (if user-generated content scales)
- User reporting system (flag inappropriate content)

---

### 9. Legal: Church Partnership Revenue Sharing
**Risk:** Tax implications, legal structure for revenue sharing.

**Mitigation:**
- Legal review: Consult tax attorney, business attorney
- Clear agreements: Revenue sharing contracts with churches
- Compliance: Proper tax reporting, 1099 forms
- Documentation: Clear terms of service, revenue sharing policy

**Build Now:**
- Legal consultation (before building)
- Terms of service (revenue sharing disclosure)
- Documentation (revenue sharing policy)

**Build Later:**
- Church partnership implementation (after legal cleared)
- Automated tax reporting (if required)

---

### 10. Technical: Faith Mode Enum Inconsistency
**Risk:** Multiple enum definitions cause bugs, type errors.

**Mitigation:**
- Canonical enum: Single source of truth (Epic 1, Ticket 1.1)
- Type safety: Strong typing, no string-based conversions
- Testing: Comprehensive tests for enum conversions
- Documentation: Clear enum usage guidelines

**Build Now:**
- Canonical enum unification (Epic 1, Ticket 1.1)
- Type-safe conversions (helper functions)
- Tests: Enum conversion tests

**Build Later:**
- Code generation (if enum values change frequently)
- Migration tooling (if enum values change)

---

## Follow-Up Questions (Max 10)

1. **Database Choice:** PostgreSQL confirmed, or prefer MongoDB/Firebase? (Recommendation: PostgreSQL for relational data)

2. **Analytics Platform:** Firebase, Mixpanel, or Amplitude? (Recommendation: Firebase for Flutter integration)

3. **Stripe Account:** Test mode setup complete? Production keys available?

4. **Church Partnerships:** Legal structure decided? Revenue sharing contracts ready?

5. **Journal Text Encryption:** End-to-end encryption required for journal text if cloud sync enabled?

6. **Offline Support:** How critical is offline-first? Can we start with online-required and add offline later?

7. **Subscription Pricing:** Free/Premium tiers and pricing points confirmed?

8. **Content Delivery:** CDN/S3 for digital products, or serve from backend?

9. **Monitoring:** Preferred monitoring tool (Datadog, New Relic, self-hosted)?

10. **Team Capacity:** Engineering team size? Can we parallelize epics, or sequential only?

---

**Document Status:** Ready for Review  
**Next Steps:** Stakeholder review, prioritize epics, assign tickets, create GitHub issues/Jira tickets

