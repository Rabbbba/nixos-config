#include "native_hwmon.h"
#include <fstream>

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {
  double value{};
  std::ifstream file{"/sys/class/hwmon/hwmon4/temp1_input"};

  if (file >> value) {
    m_temperature = value / 1000.0;
  }
}

double NativeHwmon::temperature() const { return m_temperature; }
