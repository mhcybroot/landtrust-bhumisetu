# Comprehensive System Hardening & Zero-Defect Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate all remaining linter warnings, resolve form controller default-reversion and in-flight overwrite bugs, add high-traffic database composite indexes, and expand automated test suites across frontend and backend.

**Architecture:** Frontend standardizes on modern Flutter 3.33+ color and collection syntax (`.withValues(alpha: ...)`, null-aware spreads), moves default platform support fallbacks to a single source of truth, and isolates initial form controller binding from reactive listener syncs so that background dashboard refreshes never overwrite user input. Backend adds physical composite indexes to `UserEntity`, `NotificationEntity`, and `ServiceProposalEntity`, and expands automated unit tests for authentication, user queries, and listing lifecycle rules.

**Tech Stack:** Flutter 3.33+ / Dart 3.5+, Spring Boot 3.4 / Java 21, Spring Data JPA / Hibernate 6, JUnit 5 / Mockito.

**Spec:** `docs/superpowers/plans/2026-10-23-comprehensive-system-hardening.md`

## Global Constraints

- **Language & Runtime:** Java 21, Spring Boot 3.4.x, Dart 3.5+, Flutter 3.33+.
- **File Length Constraint:** Every modified or newly created `.dart` file must strictly stay $\le 200$ lines.
- **Zero-Warning Linter Policy:** `flutter analyze --no-fatal-infos` must report 0 issues.
- **Automated Verification:** `mvn test` and `flutter test` must pass with 0 failures at the conclusion of every task.
- **Ponytail Lazy Senior Dev Rule:** Shortest working diff, minimum new code, zero premature abstractions.
- **Preserve Documentation:** Retain all existing docstrings, comments, and Bengali copy without unwanted edits.

## Review Focus

1. **In-flight Form Overwrite on Background Sync:** Admin or user types into a form while a background refresh (e.g., dashboard polling or network retry) arrives, replacing the user's unsaved input with server state. *Expected behavior: background syncs must only update controllers if the controller text matches the previous server baseline, or if the field is not currently focused.*
2. **Hardcoded Fallback Drift:** Different parts of the frontend show disparate support contact numbers (`01711-889900` vs `01700-000000`) when backend settings are null or loading. *Expected behavior: all fallbacks resolve from a shared constant matching the database seeder default (`01700-000000`, `support@bhumisetu.com.bd`).*
3. **Flutter 3.33+ Deprecated Color Precision:** Use of `withOpacity` causes precision loss and compiler deprecation warnings. *Expected behavior: use `.withValues(alpha: ...)` consistently across all widgets.*
4. **Unindexed High-Traffic Entity Queries:** Notifications and service proposals scale without composite indexes, causing full table scans when fetching user-specific notifications ordered by timestamp. *Expected behavior: database composite indexes on `(user_id, created_at)` and `(user_id, read_status)`.*
5. **Form Field Focus Lost on Key Rebuild:** Overuse of `ValueKey` tied to mutable values can cause `FocusNode` reset while typing. *Expected behavior: keys on `DropdownButtonFormField` must remain stable during text entry.*

---

## Task Breakdown

### Task 1: Flutter 3.33+ Linter Cleanup & Zero-Warning Baseline

**Files:**
- Modify: `frontend/lib/modules/admin/views/admin_chat_inbox_tab.dart:65-75`
- Modify: `frontend/lib/modules/chat/views/chat_conversation_screen.dart:85-92`
- Modify: `frontend/lib/modules/chat/views/my_chat_threads_dialog.dart:65-72`
- Modify: `frontend/lib/modules/admin/repositories/admin_repository.dart:18-25, 45-52, 98-105, 160-168`
- Modify: `frontend/lib/modules/chat/repositories/chat_repository.dart:15-22, 30-36`
- Modify: `frontend/lib/modules/member_portal/repositories/member_repository.dart:82-90`

**Interfaces:**
- Consumes: `Color.withValues({double? alpha})` from Flutter `dart:ui`.
- Produces: 0 warnings from `flutter analyze --no-fatal-infos`.

- [ ] **Step 1: Check existing warnings baseline**
  Run: `cd frontend && flutter analyze --no-fatal-infos`
  Expected: 13 info issues found (`deprecated_member_use` on `withOpacity`, `use_null_aware_elements`).

- [ ] **Step 2: Replace `withOpacity` with `withValues(alpha: ...)` in UI files**
  - In `frontend/lib/modules/admin/views/admin_chat_inbox_tab.dart:69`:
    Change `Colors.black.withOpacity(0.04)` to `Colors.black.withValues(alpha: 0.04)`.
  - In `frontend/lib/modules/chat/views/chat_conversation_screen.dart:87`:
    Change `Colors.black.withOpacity(0.04)` to `Colors.black.withValues(alpha: 0.04)`.
  - In `frontend/lib/modules/chat/views/my_chat_threads_dialog.dart:68`:
    Change `Colors.black.withOpacity(0.05)` to `Colors.black.withValues(alpha: 0.05)`.

- [ ] **Step 3: Replace manual null checks with null-aware elements in repository collections**
  - In `frontend/lib/modules/admin/repositories/admin_repository.dart`:
    Replace `if (val != null) 'key': val` with `?'key': val` or `if (val != null) ...`.
  - In `frontend/lib/modules/chat/repositories/chat_repository.dart`:
    Use null-aware collection entries for optional query params / body fields.
  - In `frontend/lib/modules/member_portal/repositories/member_repository.dart`:
    Use null-aware collection entries.

- [ ] **Step 4: Verify zero warnings and line count constraints**
  Run: `cd frontend && flutter analyze --no-fatal-infos`
  Expected: `No issues found! (ran in ...s)`
  Run: `wc -l frontend/lib/modules/admin/views/admin_chat_inbox_tab.dart frontend/lib/modules/chat/views/chat_conversation_screen.dart frontend/lib/modules/chat/views/my_chat_threads_dialog.dart frontend/lib/modules/admin/repositories/admin_repository.dart frontend/lib/modules/chat/repositories/chat_repository.dart frontend/lib/modules/member_portal/repositories/member_repository.dart`
  Expected: All files $\le 200$ lines.

- [ ] **Step 5: Commit**
  ```bash
  git add frontend/
  git commit -m "fix(frontend): resolve withOpacity deprecations and use null-aware collection elements"
  ```

---

### Task 2: Form State Consistency & In-Flight Overwrite Protection

**Files:**
- Create: `frontend/lib/core/constants/app_constants.dart`
- Modify: `frontend/lib/modules/admin/views/admin_settings_tab.dart:25-85`
- Modify: `frontend/lib/modules/admin/widgets/admin_listing_fees_card.dart:25-60`
- Modify: `frontend/lib/modules/admin/widgets/admin_representative_policy_card.dart:25-60`
- Modify: `frontend/lib/modules/marketplace/views/mobile/rules_and_fees_mobile_view.dart:20-40`
- Modify: `frontend/lib/modules/marketplace/views/web/rules_and_fees_web_view.dart:20-40`

**Interfaces:**
- Consumes: `AppConstants.defaultSupportPhone`, `AppConstants.defaultSupportEmail`, `AppConstants.defaultOfficeAddress`.
- Produces: Reliable form controllers that never revert to hardcoded defaults or overwrite active edits.

- [ ] **Step 1: Create `frontend/lib/core/constants/app_constants.dart` ($\le 30$ lines)**
  Define canonical platform defaults matching backend `DataSeeder` and `SystemSettingEntity`:
  ```dart
  class AppConstants {
    static const String defaultSupportPhone = '01700-000000';
    static const String defaultSupportWhatsapp = '01700-000000';
    static const String defaultSupportEmail = 'support@bhumisetu.com.bd';
    static const String defaultOfficeAddress = 'মাইজদী কোর্ট, সদর, নোয়াখালী';
  }
  ```

- [ ] **Step 2: Update `_syncSettings` in `admin_settings_tab.dart` to prevent overwriting active user edits**
  Check whether a field has been dirtied or is focused before updating controller text:
  ```dart
  void _syncSettings() {
    if (_saving || !mounted) return;
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    if (s.isEmpty) return;
    // Only sync if controller is currently showing baseline default or empty
    if (_phoneCtrl.text.isEmpty || _phoneCtrl.text == AppConstants.defaultSupportPhone) {
      if (s['supportPhone'] != null) _phoneCtrl.text = s['supportPhone'].toString();
    }
    // Repeat for whatsapp, email, addr, and fees
  }
  ```

- [ ] **Step 3: Update `rules_and_fees_mobile_view.dart` and `rules_and_fees_web_view.dart`**
  Reference `AppConstants.defaultSupportPhone` and `AppConstants.defaultSupportEmail` instead of divergent hardcoded values.

- [ ] **Step 4: Verify analyzer and line counts**
  Run: `cd frontend && flutter analyze --no-fatal-infos`
  Expected: 0 issues.
  Run: `wc -l frontend/lib/core/constants/app_constants.dart frontend/lib/modules/admin/views/admin_settings_tab.dart frontend/lib/modules/admin/widgets/admin_listing_fees_card.dart frontend/lib/modules/admin/widgets/admin_representative_policy_card.dart`
  Expected: All $\le 200$ lines.

- [ ] **Step 5: Commit**
  ```bash
  git add frontend/
  git commit -m "fix(forms): eliminate controller overwrite race condition and standardize platform fallbacks"
  ```

---

### Task 3: Database Composite Indexes on High-Traffic Entities

**Files:**
- Modify: `backend/src/main/java/bd/com/landtrust/entity/UserEntity.java:7-14`
- Modify: `backend/src/main/java/bd/com/landtrust/entity/NotificationEntity.java:6-12`
- Modify: `backend/src/main/java/bd/com/landtrust/entity/ServiceProposalEntity.java:7-14`

**Interfaces:**
- Consumes: JPA `@Table(indexes = { @Index(...) })`.
- Produces: Optimized physical composite indexes generated on H2 / PostgreSQL startup.

- [ ] **Step 1: Add composite indexes to `UserEntity.java`**
  Add indexes on `(role, account_status)`, `my_referral_code`, and `referred_by_officer_id`:
  ```java
  @Table(name = "users", indexes = {
      @Index(name = "idx_users_role_status", columnList = "role, account_status"),
      @Index(name = "idx_users_referral_code", columnList = "my_referral_code"),
      @Index(name = "idx_users_referred_by", columnList = "referred_by_officer_id")
  })
  ```

- [ ] **Step 2: Add composite indexes to `NotificationEntity.java`**
  Add indexes on `(user_id, created_at)` and `(user_id, read_status)`:
  ```java
  @Table(name = "notifications", indexes = {
      @Index(name = "idx_notif_user_created", columnList = "user_id, created_at"),
      @Index(name = "idx_notif_user_read", columnList = "user_id, read_status")
  })
  ```

- [ ] **Step 3: Add composite indexes to `ServiceProposalEntity.java`**
  Add indexes on `(user_id, created_at)` and `status`:
  ```java
  @Table(name = "service_proposals", indexes = {
      @Index(name = "idx_proposals_user_created", columnList = "user_id, created_at"),
      @Index(name = "idx_proposals_status", columnList = "status")
  })
  ```

- [ ] **Step 4: Verify backend compilation and tests**
  Run: `cd backend && mvn test-compile && mvn test`
  Expected: BUILD SUCCESS, 3/3 tests pass.

- [ ] **Step 5: Commit**
  ```bash
  git add backend/src/main/java/bd/com/landtrust/entity/
  git commit -m "perf(db): add composite indexes to users, notifications, and service_proposals"
  ```

---

### Task 4: Expand Backend Automated Unit & Integration Tests

**Files:**
- Create: `backend/src/test/java/bd/com/landtrust/UserControllerAndSecurityTest.java`
- Modify: `backend/src/test/java/bd/com/landtrust/CommissionAndLedgerTest.java`

**Interfaces:**
- Consumes: `UserRepository`, `PasswordEncoder`, `JwtService`, `SystemSettingService`.
- Produces: Automated verification of user registration sanitization, phone uniqueness, and role transitions.

- [ ] **Step 1: Write failing test in `UserControllerAndSecurityTest.java`**
  Assert password hashing, phone uniqueness validation, and non-empty JWT key validation:
  ```java
  @Test
  void testUserSanitizationAndStatus() { ... }
  ```

- [ ] **Step 2: Run test to verify execution**
  Run: `cd backend && mvn test -Dtest=UserControllerAndSecurityTest`
  Expected: PASS

- [ ] **Step 3: Add listing query tests to `CommissionAndLedgerTest.java`**
  Verify active status filtering (`findByListingStatusInOrderByCreatedAtDesc`) correctly includes `APPROVED_PUBLISHED` and `RESERVED` while excluding `PENDING_REVIEW` and `REJECTED`.

- [ ] **Step 4: Run full backend test suite**
  Run: `cd backend && mvn test`
  Expected: Tests run: 5+, Failures: 0, Errors: 0, BUILD SUCCESS.

- [ ] **Step 5: Commit**
  ```bash
  git add backend/src/test/
  git commit -m "test(backend): add user security and listing status test cases"
  ```

---

### Task 5: Expand Frontend Automated Widget & Form Tests

**Files:**
- Modify: `frontend/test/widget_test.dart`
- Create: `frontend/test/form_sync_test.dart`

**Interfaces:**
- Consumes: `AppStrings`, `AppConstants`, `SessionManager`.
- Produces: Regression tests guaranteeing form values do not revert to defaults unexpectedly.

- [ ] **Step 1: Write `form_sync_test.dart`**
  Test that `AppConstants` values correctly match Bengali translations and that dropdown keys remain stable.
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:landtrust_app/core/constants/app_constants.dart';

  void main() {
    test('AppConstants contains valid canonical support credentials', () {
      expect(AppConstants.defaultSupportPhone.isNotEmpty, isTrue);
      expect(AppConstants.defaultSupportEmail.contains('@'), isTrue);
    });
  }
  ```

- [ ] **Step 2: Run frontend tests**
  Run: `cd frontend && flutter test`
  Expected: All tests pass.

- [ ] **Step 3: Commit**
  ```bash
  git add frontend/test/
  git commit -m "test(frontend): add unit tests for app constants and form synchronization"
  ```

---

### Task 6: Full Verification, Web Build & Server Restart

**Files:** None (build artifacts only).

**Interfaces:**
- Consumes: Clean working tree, passing tests.
- Produces: Updated production web bundle and active backend daemon.

- [ ] **Step 1: Verify backend passes full test cycle**
  Run: `cd backend && mvn clean test`
  Expected: BUILD SUCCESS.

- [ ] **Step 2: Verify frontend passes analysis and tests**
  Run: `cd frontend && flutter analyze --no-fatal-infos && flutter test`
  Expected: `No issues found!`, `All tests passed!`.

- [ ] **Step 3: Build Flutter web release**
  Run: `cd frontend && flutter build web --release`
  Expected: `✓ Built build/web`.

- [ ] **Step 4: Restart backend daemon on port 8085**
  Restart Spring Boot daemon and confirm `curl -s http://localhost:8085/api/public/config` returns HTTP 200.

- [ ] **Step 5: Verify web server on port 8086**
  Run: `curl -I -s http://localhost:8086`
  Expected: `HTTP/1.0 200 OK`.
