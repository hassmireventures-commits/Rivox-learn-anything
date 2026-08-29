# UI Review

## Strengths

- Cohesive theme (`lib/core/theme/app_theme.dart`), wavy headers, dashboard card system.
- Iterated visual redesign documented in `docs/logs/ENHANCEMENTS_LOG.md`.
- Shared widgets (`dashboard_page_scaffold`, feature cards) improve consistency.

## Finding — Dense, card-heavy Settings / Dashboard

**Evidence:** `settings_screen.dart` ~1191 lines; `dashboard_screen.dart` ~826 lines.  
**Impact:** Visual overload; hard to scan; maintenance cost.  
**Severity:** Medium  
**Options:** Split routes; section registry; leave as-is for solo team.  
**Recommended:** Settings hub with focused routes (AI, Privacy, Goals, Data).  
**Effort:** M **Owner:** Design + Frontend

## Finding — Brand / package identity fragmentation

**Evidence:** “Learn Anything” vs `ai_quiz_app` / `com.aiquiz.ai_quiz_app`; backup strings “AI Quiz”; donate/legal placeholders.  
**Severity:** Medium  
**Recommended:** Align all user-facing brand strings before store launch; freeze applicationId if installs exist.  
**Owner:** Product + Brand

## Finding — Charts and custom headers likely low a11y

**Evidence:** Few `Semantics` usages; charts interaction disabled without accessible summaries (`dashboard_charts.dart`).  
**Severity:** High (with a11y)  
**Recommended:** Accessible labels/summaries; contrast audit light/dark.  
**Owner:** Design + A11y

## Premium bar

Target: peer to top consumer learning apps. Current: solid indie polish; not yet “premium global” due to density, incomplete locales (Tamil mojibake), and placeholder legal/ad surfaces.

## Score

UI **6.5/10**
