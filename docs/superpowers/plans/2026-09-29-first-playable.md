# 慢慢推 First Playable Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task. User has authorized inline execution.

**Goal:** Deliver a playable portrait 3D coin pusher with single-press input and persistent, pressure-free progression for Android and iOS.

**Architecture:** Pure wallet rules and atomic JSON saves are independent from the Jolt simulation. Machine owns rigid bodies and snapshot/restore; Game coordinates transactions and pause; HUD only emits user intentions.

**Tech Stack:** Godot 4.6.3, GDScript, Jolt, Compatibility renderer, Android SDK / Xcode.

## File map
- `project.godot`, `scenes/main.tscn`: engine settings and startup.
- `scripts/wallet.gd`: currency/daily/collection model.
- `scripts/save_store.gd`: validated atomic JSON with backup fallback.
- `scripts/coin.gd`, `scripts/machine.gd`: physics and machine visuals.
- `scripts/game.gd`: mode/input/save/pause orchestration.
- `scripts/hud.gd`, `scripts/feedback.gd`: responsive Chinese UI, synthesized sound/haptics.
- `assets/models/`, `assets/fonts/`, `assets/THIRD_PARTY.md`: licensed assets and records.
- `tests/test_rules.gd`, `tests/test_game.gd`: headless rules and real scene integration.
- `tools/`, `export_presets.cfg`, `README.md`: reproducible test/build instructions.

## Task 1: Rules and persistence
- [ ] Write failing assertions: initial + daily grant, same-day duplicate, next-day grant, clock rollback, insufficient balance, practice isolation, collection thresholds, corrupt primary fallback.
- [ ] Run `godot --headless --path . --script tests/test_rules.gd`; confirm missing implementation failure.
- [ ] Implement wallet and JSON save store with version/type/range validation and primary + backup.
- [ ] Run rules tests, require zero failures.

## Task 2: Physical machine and touch flow
- [ ] Write scene integration tests for one-press input, held/echo suppression, queue persistence, capacity no-debit, pause freeze and snapshots.
- [ ] Build static shelves, walls and a sinusoidal animatable pusher; use cylinder coin colliders with sleeping and CCD.
- [ ] Add seeded coin bed, real score/side detection, queued drops, scene serialization and mode isolation.
- [ ] Run Godot import and headless physics tests; tune overlap, fall boundaries and forward movement.

## Task 3: Presentation
- [ ] Download suitable CC0 assets and OFL font, preserve licenses.
- [ ] Add polished portrait HUD with safe-area adaptation, big press button, location selector, daily/collection/help/pause panels and disabled-input feedback.
- [ ] Add optional sound and haptics, score feedback and press animation.
- [ ] Launch native window; capture screenshot and inspect; fix clipping/contrast/layout.

## Task 4: Mobile deliverables
- [ ] Configure Android and iOS presets without private credentials.
- [ ] Export Android debug APK and verify manifest and signing; install/launch emulator if available.
- [ ] Export unsigned iOS Xcode project and build/run simulator if installed. Record blockers honestly.
- [ ] Run all tests after fixes; write README with exact commands and remaining device QA.
- [ ] Update checklist and commit all source/assets/docs, exclude builds/tools/caches.
