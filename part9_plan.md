# LinguaLens Part 9 Implementation Plan

## Goal

Upgrade the completed Parts 1–8 LinguaLens Flutter app into a premium, compact, production-quality tuition-management product without rebuilding its business architecture. Preserve the existing offline-first Hive storage, Riverpod providers, go_router navigation, bilingual English/Bangla localization, light/dark themes, backup/restore, messaging, and synchronization behavior while introducing the Part 9 UX and workflow enhancements.

The implementation will follow the brief’s required sequence: design-system refactor, global layout pass, student batch assignment, preferred schedule, batch schedule builder, attendance calendar redesign, attendance home/mark polish, dashboard polish, students/batches/fees visual pass, world-class onboarding, final motion/accessibility polish, and regression validation.

## Current baseline and constraints

The repository is `/home/ubuntu/LinguaLens`, currently on the Part 8 implementation with a clean pushed baseline. The app is Flutter/Dart, uses Hive with manual adapters, Riverpod 3, go_router, table_calendar, image_picker, url_launcher, intl, and a local-only business-data architecture. Existing routes, providers, repositories, backup schema, and cross-module invalidation must remain compatible.

The target is Android-first and iOS-compatible, with a release web preview used for visual verification. All visible text must use the existing localization system. New persisted fields must be optional, default-safe, and migration-safe. The app must remain usable at narrow Android widths, support system text scaling and safe areas, and keep touch targets at least 44–48 dp.

## Implementation phases

### Phase 1 — Establish the premium design system

1. Audit the current theme and shared widgets, then introduce or consolidate premium color, spacing, radius, typography, border, shadow, and semantic finance tokens. Use the Part 9 light palette centered on indigo `#4F46E5`, neutral `surfaceBase`/`surfaceElevated` layers, and semantic success, warning, error, info, due, and money colors. Create a genuinely dark palette with rich surfaces and subtle borders rather than simply inverting light colors.
2. Keep the existing locale-dependent Poppins/Noto Sans Bengali behavior and refine the type scale around screen titles, section titles, card titles, body text, metadata, stat values, and captions. Validate Bangla line height and overflow.
3. Upgrade or add reusable `PremiumCard`, `PremiumSection`, `PremiumStatPill`, `PremiumToggleTile`, and `CurrencyAmountText` primitives. Refine buttons, chips, scaffold/app-bar chrome, ghost icon buttons, separators, loading/error/empty states, and press feedback. Use controlled radius values of 8/12/16/20/24 and border-first surfaces with short, soft light-theme shadows and almost no dark-theme shadows.
4. Upgrade `formatFee()` to use `intl` thousand separators, omit unnecessary decimals, and preserve meaningful decimals. Implement `CurrencyAmountText` with separated, slightly de-emphasized `৳` and stronger numerals, size variants, semantic tones, optional plus sign, and compact mode.

### Phase 2 — Apply the global premium layout pass

1. Refactor major app bars and screen backgrounds to use compact title alignment, subtle dividers, safe-area-aware content, and premium ghost controls.
2. Replace oversized or generic full-width cards with compact grouped sections, nested card groups, stat wraps, and clear visual framing. Reduce unnecessary vertical whitespace while retaining an 8-point rhythm and readable content density.
3. Apply the shared primitives consistently across the shell, More menu, dashboard, student/batch/attendance/lesson/message/fee screens, settings, and backup screens. Preserve existing routes and provider behavior.
4. Add or retain standardized loading, empty, error, confirmation, and success feedback. Destructive operations remain confirmed and all feedback is localized.

### Phase 3 — Add student batch assignment workflow

1. Extend `student_form_screen.dart` to load all active batches using the existing batch provider/repository APIs. Display a compact, responsive premium toggle-card section titled “Batch Assignment.” Use a two-column layout when width allows and a stacked layout on narrow screens.
2. Each toggle tile will show a batch color dot, name, subject/schedule summary, selected state, and accessible semantic label. Selected tiles use primary-soft fill, primary border, and a check icon; unselected tiles use an elevated surface and subtle border. Add compact inline joining-date and default-fee chips for selected batches, with an optional small edit affordance only if the existing data model supports it safely.
3. In add mode, initialize all selections off. In edit mode, load active enrollments and preselect them. If there are no active batches, show a localized compact empty/information state with a route to create a batch.
4. Expand the student save orchestration without moving business logic into UI unnecessarily. On add, save the student, then create active enrollments for selected batches with today’s joining date, zero custom fee by default, and active status. On edit, diff selected IDs against existing enrollment history: create missing enrollments, reactivate inactive matching records, and mark deselected active enrollments inactive rather than deleting history.
5. Invalidate student, batch, batch-detail, attendance expected-count, dashboard, search, and applicable fee providers after changes. Ensure failures surface through the shared error/snackbar system and do not leave partially updated UI state.

### Phase 4 — Add migration-safe preferred student schedule

1. Add optional Hive fields 14–16 to `StudentModel` and matching fields to `StudentEntity`: `preferredStartTime` (`String`, default empty), `preferredWeekdays` (`List<int>`, default empty), and `preferredScheduleNote` (`String`, default empty). Update manual adapter read/write and JSON serialization with safe defaults for old records. Do not alter existing TypeIds or field indexes.
2. Add a “Preferred Schedule” form section with Saturday-first weekday chips (`Sat` through `Fri`), a compact premium time card, and an optional note field. Use `showTimePicker` with `TimePickerEntryMode.dial`, a custom theme, and `--:--` before selection. Store selected time as 24-hour `HH:mm` while rendering localized human-readable time.
3. Show a compact schedule preview such as `Sat, Mon, Wed • 6:30 PM`, with Bangla localization and safe wrapping. Save and reload all fields in add and edit modes.
4. Add a preferred-schedule card to student detail and a compact time chip to student list rows when available; otherwise show a subtle localized “Not set.” Invalidate student list/detail and global-search providers after schedule changes.

### Phase 5 — Upgrade batch schedule input

1. Replace the batch form’s free-text-first schedule experience with a structured premium builder while retaining `scheduleText` as the persisted compatibility field.
2. Add Saturday-first day chips, start and end dial time pickers, and an optional custom note. Generate readable schedule text such as `Sat, Mon, Wed • 8:00 AM – 9:30 AM` and preserve a safe fallback for manually entered legacy schedule text.
3. Reuse the same toggle/time-card primitives as student preferred schedules so both workflows feel consistent. Ensure student batch-assignment cards show the generated schedule summary.
4. Preserve existing batch CRUD and invalidate all dependent providers after save.

### Phase 6 — Redesign the student attendance calendar

1. Refactor the current `student_attendance_screen.dart`/attendance calendar implementation without changing its provider/repository contract. Build four layers: compact profile header, analytics strip, premium calendar card, and selected-date detail panel.
2. The profile header will show avatar, student name/code, attendance percentage, and present/absent mini pills. The analytics strip will show Present, Absent, Late, Leave, and Total Marked with semantic colors and compact stat styling.
3. Deeply customize `TableCalendar`: remove harsh default borders, add a custom `← August 2026 →` month header with an “Attendance Overview” subtitle, refine weekday labels, selected/today styling, and premium status markers. Render an aggregate daily bottom strip or capsule using a documented priority rule for mixed statuses, with absent strongest, late amber, present green, and leave muted.
4. Add monthly stats for attendance percentage, marked days, and absent days above the grid. Below the calendar, animate the selected-date panel with a subtle fade/slide and show localized full date, batch-color dots, status chips, note previews, and a compact empty state when no record exists. Replace the flat legend with rounded legend pills.
5. Keep month/date changes and attendance edits synchronized with student summary, batch detail, dashboard, and all existing invalidation paths. Verify data accuracy against repository records.

### Phase 7 — Polish attendance home and marking

1. Refactor attendance batch cards into denser dashboard-like cards with a color strip, batch identity, subject chip, selected date row, summary pills, emphasized unmarked count, and right-aligned compact CTA.
2. Refine status chips into tactile capsules with icons, short localized labels, filled selected states, outlined unselected states, and minimum touch targets.
3. Compactify student attendance rows, refine the date selector into a segmented-control-like bar, keep summary chips visible under the app bar where appropriate, and upgrade the save bar to a premium anchored action surface.
4. Preserve loading, empty, error, keyboard, safe-area, and state-sync behavior.

### Phase 8 — Refactor the dashboard

1. Rebuild the dashboard hierarchy as a compact command center: top app bar, greeting hero, horizontal stat cards, quick actions grid, attendance/lessons/fees groups, and recent activity.
2. Keep the Part 8 backup reminder, settings-driven section visibility, search shortcut, and localized greeting behavior intact. Use grouped sections and premium stat cards with context labels rather than large blank areas.
3. Refine quick actions into compact square-ish tactile tiles with muted surfaces and consistent icon containers. Refine lesson, fee, attendance, and recent-activity rows using the shared list/card system and standardized empty/loading/error states.

### Phase 9 — Premium students, batches, and fees pass

1. Refactor student list rows to show avatar, name/status, code/class, parent/phone, batch-count chip, and preferred-time chip within a compact two-line information hierarchy.
2. Refactor student details into profile, contact, preferred schedule, enrolled batches, attendance, fees, and communication blocks. Keep existing message and attendance routes.
3. Refactor batch list/detail cards and sections, including the new schedule summary and batch messaging CTA. Preserve enrollment and lesson flows.
4. Apply `CurrencyAmountText` and finance pills throughout dashboard fee cards, fee summaries, fee records, payment tiles, batch/student fee blocks, and collect-payment summary rows. Use green paid, red due, and amber partial semantics with accessible text labels in addition to color.

### Phase 10 — World-class onboarding

1. Replace the current generic five-page onboarding with a premium layered full-screen experience while preserving the guarded route and persisted completion state.
2. Build five concise steps: brand/value; mini student/fee/attendance UI preview; lesson planning/batch organization cards; parent communication and backup trust; and interactive setup.
3. Use neutral surfaces, restrained gradients, layered mini UI cards, animated progress, smooth transitions, subtle stagger/parallax where performant, and a strong thumb-zone CTA. Avoid cartoon art and excessive effects.
4. On the final step, save selected language, theme, and optional teacher name through existing settings/storage providers, invalidate locale/theme/settings/dashboard state, mark onboarding complete, and route to dashboard. Honor reduced-motion preferences where available.

### Phase 11 — Motion, accessibility, and consistency polish

1. Add 180 ms toggle transitions, 0.985 press scale on interactive cards, gentle stat value transitions, calendar panel transitions, onboarding stagger, and `AnimatedSwitcher` section changes. Avoid bouncy or expensive animations.
2. Audit all interactive controls for 44–48 dp targets, semantic labels, keyboard/focus behavior on web, screen-reader text, safe-area insets, text scaling, contrast, non-color status cues, and localized content.
3. Verify dark theme surfaces, borders, finance colors, cards, dialogs, navigation, and onboarding are intentionally designed rather than inverted. Check Bangla wrapping and line height on narrow screens.
4. Run the app through the debug workflow if any runtime issue appears: form explicit hypotheses, collect runtime evidence, fix only confirmed causes, verify after the fix, then remove temporary instrumentation.

### Phase 12 — Regression validation and delivery

1. Run formatting, analyzer, unit/widget tests, release web build, and Android debug APK build if the environment has an Android SDK. If the SDK is unavailable, record that limitation without treating it as an application failure.
2. Test existing flows: onboarding completion and restart, dashboard navigation, student CRUD, batch CRUD, student-to-batch assignment in add/edit modes, inactive enrollment history preservation, attendance marking/calendar accuracy, lesson planning, fees/payment recording, messages, backup/export/restore, settings/theme/locale, search, and More navigation.
3. Test new fields against old records and fresh records, including null/missing Hive fields and JSON backup/restore compatibility. Verify provider invalidation and cross-module refresh after student, enrollment, schedule, batch, and attendance changes.
4. Perform visual checks on the release preview at narrow mobile width and a larger web viewport for Dashboard, Students, Student Form, Student Detail, Attendance Home, Attendance Calendar, Attendance Mark, Fees, Messages, Settings, Backup & Restore, Search, and Onboarding. Check both English/Bangla and light/dark themes where practical.
5. Review `git diff --check`, keep the working tree clean, commit with a descriptive Part 9 message, push to `main`, and provide the GitHub commit plus preview URLs and validation results.

## Key assumptions

- Existing Part 8 providers and repositories remain the source of truth; no backend or business-data API will be introduced.
- `scheduleText` remains the batch persistence format unless the current model makes a safe additive structured schema preferable; any new fields will be optional and migration-safe.
- Student preferred schedule is informational only and will not automatically create lessons or alter attendance generation.
- SharedPreferences and the existing Hive metadata/settings approach remain compatible; no destructive migration of user business data is planned.
- The existing `table_calendar`, `intl`, and image-picker dependencies are sufficient; dependencies will only be added if the current lockfile proves a required capability is unavailable.
- Visual polish will prioritize the mobile baseline around 375–430 dp and preserve responsive web preview behavior.

## Main risks and mitigations

| Risk | Mitigation |
|---|---|
| Manual Hive adapters misread old records | Use new field indexes only, safe type checks/defaults, JSON compatibility tests, and startup recovery limited to metadata boxes. |
| Student save creates inconsistent enrollments | Implement a single add/edit orchestration path, preserve inactive history, await each repository mutation, and invalidate all dependent providers after completion. |
| Attendance calendar redesign breaks provider behavior | Keep provider queries and selected-date state contracts unchanged; refactor rendering only, then compare rendered totals with repository fixtures. |
| Premium visual changes cause overflow in Bangla or narrow screens | Test 375 dp layouts, use flexible/wrap layouts, text scaling, and localized strings; avoid fixed-width text containers. |
| Dark theme becomes an inverted light theme | Use dedicated dark semantic tokens, border contrast, and visual review of cards, chips, dialogs, and finance states. |
| Animation harms performance or accessibility | Use short implicit animations, avoid expensive blur/large rebuilds, respect reduced-motion signals where available, and verify release web performance. |
| Existing routes or shell behavior regress | Preserve canonical route constants and existing route paths; add focused smoke tests for shell branches and deep links. |
| Android validation is unavailable in the sandbox | Run all Dart/web validation regardless and report the SDK limitation explicitly if APK compilation cannot run. |

## Completion criteria

The work is complete only when the Part 9 UX requirements are implemented as compilable Flutter code, old Part 1–8 workflows remain functional, student batch auto-assignment and preferred schedule work in add/edit flows, attendance calendar analytics remain data-accurate, money display is consistent, onboarding persists setup, light/dark and English/Bangla modes are visually usable, release validation passes, the final preview is reviewed, and the changes are committed and pushed to GitHub.
