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

## Style — Gruvbox Dark (palette projet)

**Convention du projet** : tout le styling de la barre utilise la palette Gruvbox Dark.

### Backgrounds
| Couleur | Hex | Usage |
|---|---|---|
| bg0_h | `#1d2021` | hard background |
| bg0   | `#282828` | background principal de la barre |
| bg1   | `#3c3836` | element vide / inactif |
| bg2   | `#504945` | hover léger |
| bg3   | `#665c54` | bordures |
| bg4   | `#7c6f64` | bordures plus visibles |

### Foregrounds
| Couleur | Hex | Usage |
|---|---|---|
| fg0 | `#fbf1c7` | texte le plus clair |
| fg1 | `#ebdbb2` | texte standard ← défaut |
| fg2 | `#d5c4a1` | texte secondaire |
| fg3 | `#bdae93` | texte tertiaire |
| fg4 | `#a89984` | texte désactivé / indicateur "occupé" |

### Accents (bright variants — privilégier)
| Couleur | Hex | Usage |
|---|---|---|
| red    | `#fb4934` | urgent, erreur |
| green  | `#b8bb26` | success, ok |
| yellow | `#fabd2f` | tag actif, focus, attention douce |
| blue   | `#83a598` | info |
| purple | `#d3869b` | accent |
| aqua   | `#8ec07c` | accent |
| orange | `#fe8019` | warning |

### Variants normaux (si on veut plus sourd)
red `#cc241d`, green `#98971a`, yellow `#d79921`, blue `#458588`, purple `#b16286`, aqua `#689d6a`, orange `#d65d0e`.

*(Phase 5 ajoutera transitions, hover, animations basés sur cette palette.)*

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
