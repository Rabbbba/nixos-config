#include "native_hwmon.h"
#include <QTimer>
#include <filesystem>
#include <fstream>

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {
  mTimer.setInterval(2000);
  connect(&mTimer, &QTimer::timeout, this, &NativeHwmon::poll);
  mSensorPath = discoverSensor();
  poll();
  mTimer.start();
}

double NativeHwmon::temperature() const { return mTemperature; }

void NativeHwmon::poll() {
  double newValue{};
  std::ifstream file{mSensorPath};
  if (file >> newValue) {
    double celsius{newValue / 1000.0};
    if (celsius != mTemperature) {
      mTemperature = celsius;
      emit temperatureChanged();
    }
  }
}

std::string NativeHwmon::discoverSensor() const {
  for (const auto &element :
       std::filesystem::directory_iterator{"/sys/class/hwmon/"}) {
    std::filesystem::path path = element.path() / "name";
    std::ifstream file{path};
    std::string name;
    if (file >> name) {
      if (name == "k10temp") {
        return (element.path() / "temp1_input").string();
      }
    }
  }
  return {};
}
