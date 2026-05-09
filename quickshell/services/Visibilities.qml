pragma Singleton
import QtQuick

/**
 * @brief Single source of truth for which popout is currently shown.
 *
 * Modules call @ref toggle on click to open/close their popout; popouts
 * bind their `visible` to `Visibilities.current === "name"`. Guarantees
 * that only one popout is open at a time.
 */
QtObject {
    id: root

    /** Name of the currently visible popout, or empty string if none. */
    property string current: ""

    /**
     * Toggles popout `name`: opens it if closed, closes it if open.
     * @param name Unique popout identifier (e.g. "cpu", "gpu", "tidal").
     */
    function toggle(name: string): void {
        if (current === name)
            current = "";
        else
            current = name;
    }

    /** Closes any currently open popout. */
    function close(): void {
        current = "";
    }
}
