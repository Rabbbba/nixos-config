# Roadmap

The direction of this config, built around one idea:

> Move from *assembling third-party packages* to *building the tools myself*.

This setup is not frozen. The goal is to progressively replace third-party desktop components with in-house implementations (Quickshell / C++), while raising the engineering bar (tests, CI, documentation). Every item is meant to be **shipped, documented, and maintainable**.

Status: `planned` · `in progress` · `done` · `idea`

Workflow:
- `ROADMAP.md` explains the direction and why each area matters.
- GitHub issues break the roadmap into trackable work.
- Pull requests close issues and include validation commands.
- `AUDIT.md` stays private and is used as an internal review log; actionable findings are promoted into public issues.

## Pillar A — Build: move what can be moved into Quickshell

Replace desktop daemons and tools with custom Quickshell modules. Ordered from most accessible to most complex.

| # | Item | Replaces | Status | Difficulty |
|---|------|----------|--------|-----------|
| A1 | Notification daemon — implement `org.freedesktop.Notifications`, render toasts in QML | `dunst` | planned | medium |
| A2 | Wallpaper + theme picker — bar-integrated UI, drives matugen, applies per EDID output | `wallpaper.sh` / matugen front | planned | medium |
| A3 | Audio visualizer — spectrum drawn in QML/Canvas from the PipeWire stream | `cava` | planned | high |
| A4 | Application launcher — search and launch, in QML | `walker` + `elephant` | planned | very high |
| A5 | Dashboard système — sparklines + jauges CPU/RAM/GPU/Net/Disques, tout en QML, alimenté par les capteurs `NativeSensors` | `btop` / `mission-center` | planned | medium |
| A6 | Sélecteur de profil de performance — 3 profils déclaratifs Nix (Desktop/Game/Powersave), popout QML, bascule gouverneur CPU + GPU + MangoHud | scripts shell + `gamemode` standalone | planned | medium |
| A7 | Gestionnaire de presse-papiers — popout listant l'historique `cliphist`, recherche, pin/delete | UI `cliphist` inexistante | planned | easy |
| A8 | OSD unifié — volume, micro, luminosité, layout clavier, HDR, profil de performance | feedback dispersé entre scripts/outils | idea | medium |
| A9 | Centre de notifications — historique, groupement par application, actions, do-not-disturb | historique `dunst` / aucun centre intégré | idea | high |
| A10 | Screenshot studio — capture zone/fenêtre/écran, OCR, color picker, copie presse-papiers | scripts `grim`/`slurp`/`swappy` isolés | idea | medium |
| A11 | Quick settings — toggles Wi-Fi, Bluetooth, audio sink, VPN/Tailscale, HDR, idle inhibitor, reload shell | scripts + commandes dispersées | idea | high |
| A12 | NixOS update center — statut flake, rebuild/test, générations, rollback, logs | terminal `nh` manuel | idea | high |
| A13 | Workspace overview — vue des workspaces/fenêtres Hyprland, recherche et focus rapide | overview absent / `hyprctl` manuel | idea | very high |
| A14 | Alertes système intelligentes — températures, disque plein, réseau, services systemd en erreur | monitoring manuel | idea | easy → medium |

Boundary: Quickshell is the **UI layer** of the desktop. System plumbing (DNS, kernel, low-level networking, audio server) stays with the right tools — nothing gets reinvented for its own sake.

Rule: Quickshell owns presentation and orchestration. Privileged or low-level actions stay behind declarative Nix config, systemd units, or small audited scripts.

Milestones:

| Milestone | Items | Notes |
|-----------|-------|-------|
| `v1.0 — Desktop essentials` | A1, A2, A5, A7 — optional: A3 | Short, shippable, visible features |
| `v1.1 — Launcher MVP` | A4 only | High-risk item — isolated milestone, do not bundle |
| `v1.2 — System controls` | A6, A11, A12 | Privileged and system-facing actions |

A8–A14 (except A11, A12) remain `idea` and are promoted into milestones once the core shell is stable.

Architecture constraint — A12: the QML UI must not directly execute privileged rebuild or update commands. Privileged actions must go through audited scripts or systemd units. A read-only viewer (flake status, generations) is an acceptable first version before adding privileged triggers.

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

- Factor the repetitive systemd user services into a reusable Nix helper (`mkGraphicalService`) — a good Nix abstraction exercise. Tracked in [#4](https://github.com/Rabbbba/nixos-config/issues/4).
- Make `nix flake check` reproduce the pre-commit validation path reliably. Tracked in [#19](https://github.com/Rabbbba/nixos-config/issues/19).
- Align the Nix cache policy between the local config and GitHub Actions. Tracked in [#20](https://github.com/Rabbbba/nixos-config/issues/20).
- Align the repository's git identity. Done.
- Clean up duplicate package entries and a stale CMake target name. Done.

## Reading progress

Each item above is broken into GitHub **issues** (labeled by area: `area:quickshell`, `area:nix`, `area:cpp`, `area:ci`), grouped into milestones when useful, and tracked on the **project board**. An issue closes via a linked conventional commit or PR (`feat(native-sensors): … (closes #N)`).

Current recommended order:

1. Fix validation reproducibility: [#19](https://github.com/Rabbbba/nixos-config/issues/19).
2. Refactor systemd user-service boilerplate: [#4](https://github.com/Rabbbba/nixos-config/issues/4).
3. Make `NativeRam` / `NativeNetwork` fixture-testable: [#10](https://github.com/Rabbbba/nixos-config/issues/10).
4. Add C++ fixture tests: [#11](https://github.com/Rabbbba/nixos-config/issues/11).
5. Add the headless CI test job: [#13](https://github.com/Rabbbba/nixos-config/issues/13).
