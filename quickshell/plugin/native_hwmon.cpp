#include "native_hwmon.h"

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {}

double NativeHwmon::temperature() const { return m_temperature; }
