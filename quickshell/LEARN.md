# Quickshell Bar — Notes d'apprentissage

> Tes notes perso pendant la construction de la barre. Remplis au fur et à mesure que tu rencontres un concept. Écrire toi-même = retenir.

---

## Architecture du projet

### Layout des fichiers
*(Quel rôle a chaque fichier dans le projet : shell.qml, modules/, qmldir...)*

### Comment Quickshell trouve la config
*(Où Quickshell lit le shell.qml, comment on linke ça via home-manager...)*

---

## QML basics

### `property` et bindings
*(Pourquoi déclarer une property, comment marche une binding, exemple concret...)*

### `id`
*(À quoi ça sert, quand l'utiliser...)*

### Signal handlers `onXxx`
*(Comment réagir à un signal, ex. `onLoaded`, `onTriggered`...)*

### `Timer`
*(Propriétés clés : interval, running, repeat, triggeredOnStart...)*

---

## Layouts (Qt QtQuick)

### `Column` / `Row`
*(Empilement vertical/horizontal, spacing...)*

### `anchors`
*(centerIn, fill, margins... vs `x/y` absolus...)*

---

## Quickshell.Io

### `FileView`
*(Lire un fichier, propriétés path / blockLoading / text() / reload(), signal `loaded`...)*

### `Process`
*(Pas encore vu — à remplir quand on l'aura utilisé)*

---

## Quickshell (root module)

### `FloatingWindow`
*(Fenêtre flottante normale, utile pour tester en isolation...)*

### `PanelWindow`
*(Pas encore vu — Phase 4, ancrage Wayland en bord d'écran)*

---

## Quickshell.Hyprland / Mango IPC
*(Phase 3 — communication avec le compositor pour les tags)*

---

## Style / Animations
*(Phase 5 — couleurs gruvbox, transitions, hover, polish)*

---

## Cheatsheet doc

- **Quickshell types** : https://quickshell.outfoxxed.me/docs/types/
- **Qt QtQuick** : https://doc.qt.io/qt-6/qtquick-qmlmodule.html
- **Qt QML reference** : https://doc.qt.io/qt-6/qmltypes.html

### Méthode de recherche
1. Concept système (IO, panel, audio, IPC) → Quickshell docs
2. Concept visuel (layout, animation, Text/Rectangle) → Qt QtQuick docs
3. API d'un type connu : page dédiée du type, sections Properties / Methods / Signals
4. Si doc floue : grep dans `/nix/store/...quickshell.../qmltypes` (source de vérité brute)

---

## Pièges rencontrés
*(Notes sur les trucs qui m'ont pris du temps : qmldir indenté, typo ML_IMPORT_PATH, qmlls qui résout mal les composants custom...)*
