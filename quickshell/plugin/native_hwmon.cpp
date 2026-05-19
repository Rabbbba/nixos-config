#include "native_hwmon.h"
#include <QTimer>
#include <fstream>

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {
  m_timer.setInterval(2000);
  connect(&m_timer, &QTimer::timeout, this, &NativeHwmon::poll);
  poll();
  m_timer.start();
}

double NativeHwmon::temperature() const { return m_temperature; }

void NativeHwmon::poll() {
  double newValue{};
  std::ifstream file{"/sys/class/hwmon/hwmon4/temp1_input"};
  if (file >> newValue) {
    double celsius{newValue / 1000.0};
    if (celsius != m_temperature) {
      m_temperature = celsius;
      emit temperatureChanged();
    }
  }
}
