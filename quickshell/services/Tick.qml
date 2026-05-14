pragma Singleton
import QtQuick

/**
 * @brief Global 500 ms tick — single source of truth for polled services.
 *
 * Every service that needs a 500 ms poll cadence (CPU, RAM, GPU) listens to
 * this singleton's @ref tick signal instead of running its own @c Timer.
 * Without this, each service starts its timer at a different phase and the
 * three modules visibly refresh out of sync in the bar.
 */
QtObject {
    id: root

    /** @brief Emitted every 500 ms. Services connect via @c Connections. */
    signal tick

    property Timer _t: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.tick()
    }
}
