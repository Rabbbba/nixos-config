pragma Singleton
import QtQuick

// Single source of truth for which popout is currently shown.
// Modules call Visibilities.toggle("name") on click; popouts bind their
// `visible` to (Visibilities.current === "name"). Only one popup at a time.
QtObject {
    id: root

    property string current: ""

    function toggle(name) {
        if (current === name)
            current = "";
        else
            current = name;
    }

    function close() {
        current = "";
    }
}
