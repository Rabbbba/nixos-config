import QtQuick
import NativeSensors

/** @brief Smoke test for the NativeSensors plugin — logs the temperature and exits. */
QtObject {
    /** @brief NativeHwmon instance under test. */
    property NativeHwmon hwmon: NativeHwmon {}

    Component.onCompleted: {
        console.log("Plugin loaded. temperature =", hwmon.temperature);
        Qt.quit();
    }
}
