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

## Quickshell.Hyprland IPC
*(Phase 3 — communication avec le compositor pour les tags)*

---

## Style — palette matugen + tokens sémantiques

**Convention du projet** : on ne hardcode jamais une couleur dans un module. Tout passe par le singleton `modules/Theme.qml`, dont le contenu est régénéré par [matugen](https://github.com/InioX/matugen) à chaque changement de wallpaper (palette Material You 3).

### Tokens disponibles
Définis dans `Theme.qml`, nommés par rôle (pas par "Gruvbox bg0/bg1"…) :

| Token | Rôle |
|---|---|
| `windowBg` | fond de la barre / fenêtre principale (le plus sombre) |
| `popupBg` | fond des popouts (Calendar, Tidal, Power) |
| `moduleBg` | fond des modules au repos / des tooltips |
| `border` | bordures et séparateurs subtils |
| `text` | texte principal sur fond sombre |
| `textMuted` | texte secondaire (jours de la semaine, sous-titres) |
| `accent` | états actifs, highlights |
| `alert` | urgent, erreurs |

Plus les durées d'animation (`animFast`, `animSlow`) et les tailles de fonte (`fontSizeMd`, `fontSizeLg`).

### Comment ça marche en bout de chaîne
1. matugen lit le wallpaper courant
2. génère une palette Material You 3
3. injecte les hex dans le template `matugen/templates/Theme.qml`
4. écrit le résultat dans `quickshell/modules/Theme.qml`
5. Quickshell re-render avec les nouvelles couleurs (hot-reload via `settings.watchFiles`)

Quand on ajoute une couleur sémantique nouvelle, on :
1. ajoute la `readonly property color X` dans `matugen/templates/Theme.qml`
2. regenère via swap de wallpaper (ou édite manuellement Theme.qml en attendant)
3. on l'utilise dans les modules : `color: Theme.X`

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
states est réservé dans un Item
Mutation in-place d'array ne déclenche pas de binding -toujours réassigner
