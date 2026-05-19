import QtQuick
import NativeSensors

/** @brief Smoke test for the NativeSensors plugin — logs the temperature on every change. */
Item {                                            // ← Item au lieu de QtObject
    /** @brief NativeHwmon instance under test. */
    property NativeHwmon hwmon: NativeHwmon {}

    Component.onCompleted: console.log("Initial temperature =", hwmon.temperature)

    Connections {
        target: hwmon
        function onTemperatureChanged() {
            console.log("Temperature changed =", hwmon.temperature);
        }
    }
}
