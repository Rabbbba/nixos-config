import QtQuick
import "../modules"

// Text with theme defaults — used everywhere instead of raw `Text {}`
// so colors and fonts stay consistent and ellipsis is on by default.
Text {
    color: Theme.fg1
    font.family: Theme.fontFamily
    elide: Text.ElideRight
}
