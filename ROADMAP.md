# Roadmap

The direction of this config, built around one idea:

> Move from *assembling third-party packages* to *building the tools myself*.

This setup is not frozen. The goal is to progressively replace third-party desktop components with in-house implementations (Quickshell / C++), while raising the engineering bar (tests, CI, documentation). Every item is meant to be **shipped, documented, and maintainable**.

Status: `planned` · `in progress` · `done` · `idea`

## Pillar A — Build: move what can be moved into Quickshell

Replace desktop daemons and tools with custom Quickshell modules. Ordered from most accessible to most complex.

| # | Item | Replaces | Status | Difficulty |
|---|------|----------|--------|-----------|
| A1 | Notification daemon — implement `org.freedesktop.Notifications`, render toasts in QML | `dunst` | planned | medium |
| A2 | Wallpaper + theme picker — bar-integrated UI, drives matugen, applies per EDID output | `wallpaper.sh` / matugen front | planned | medium |
| A3 | Audio visualizer — spectrum drawn in QML/Canvas from the PipeWire stream | `cava` | planned | high |
| A4 | Application launcher — search and launch, in QML | `walker` + `elephant` | planned | very high |

Boundary: Quickshell is the **UI layer** of the desktop. System plumbing (DNS, kernel, low-level networking, audio server) stays with the right tools — nothing gets reinvented for its own sake.

Milestone: `v1 — Home-grown desktop` (groups A1–A4).

## Pillar B — Documentation

Make the design decisions and the C++ internals explicit, so the codebase is easy to follow.

| # | Action | Status |
|---|--------|--------|
| B1 | Document architecture decisions — why `mkOutOfStoreSymlink`, why systemd over exec-once, why cross-window `mapToGlobal`, etc. (already well underway) | in progress |
| B2 | Comment the C++ plugin — each `NativeSensor*` class with its role, lifecycle, and pitfalls (counter overflow, `error_code`) | planned |
| B3 | Quickshell architecture diagram — layer overview (shell → modules → popouts → services → plugin), readable in 30 seconds | idea |

## Pillar C — Tests and CI

Adding automated tests and tightening the CI. The area I most want to strengthen, and where I have the most to learn.

| # | Action | Tool | Status |
|---|--------|------|--------|
| C1 | Make the C++ plugin testable — parameterize the sysfs/proc roots (`NativeRam`, `NativeNetwork`) the way `NativeHwmon` already does | refactor | planned |
| C2 | C++ unit tests — sensors tested against fixture files (no real hardware required) | Qt Test / GoogleTest | planned |
| C3 | QML unit tests — pure services first (`History.js`, CPU/RAM/network math) | Qt Quick Test | planned |
| C4 | CI `test` job — PR fails if a test breaks, headless run (`QT_QPA_PLATFORM=offscreen`) | GitHub Actions | planned |
| C5 | Status badge + coverage (optional, later) | — | idea |

Tooling choice, documented: Qt Quick Test + Qt Test are chosen (native to Qt, free, runnable in CI). Squish was evaluated and dropped — a paid commercial product, incompatible with a public repository that anyone should be able to clone and run.

Milestone: `v2 — Rigor & tests` (groups C1–C4).

## Continuous hygiene

Smaller quality improvements, handled along the way:

- Factor the repetitive systemd user services into a reusable Nix helper (`mkGraphicalService`) — a good Nix abstraction exercise.
- Align the repository's git identity.
- Clean up duplicate package entries and a stale CMake target name.

## Reading progress

Each item above is broken into GitHub **issues** (labeled by area: `area:quickshell`, `area:nix`, `area:cpp`, `area:ci`), grouped into **milestones** (`v1`, `v2`), tracked on the **project board**. An issue closes via a linked conventional commit (`feat(notif): … (closes #N)`).
