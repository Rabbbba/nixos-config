#include "native_hwmon.h"
#include <QDebug>
#include <QTimer>
#include <filesystem>
#include <fstream>
#include <qlogging.h>
#include <qtmetamacros.h>
#include <string>

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {
  mTimer.setInterval(2000);
  connect(&mTimer, &QTimer::timeout, this, &NativeHwmon::poll);
  mHwmonDir = discoverSensor();
  poll();
  mTimer.start();
}

double NativeHwmon::temperature() const { return mTemperature; }

void NativeHwmon::poll() {
  double newValue{};
  if (mHwmonDir.empty())
    return;
  std::ifstream file{mHwmonDir + "/temp" + std::to_string(mTempIndex) +
                     "_input"};
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
    if (!(file >> name))
      continue;
    if (name != mSensorName.toStdString())
      continue;
    return (element.path()).string();
  }
  qWarning() << "NativeHwmon: no hwmon matched sensor name" << mSensorName;
  return {};
}

QString NativeHwmon::sensorName() const { return mSensorName; }

void NativeHwmon::setSensorName(const QString &name) {
  if (name == mSensorName)
    return;
  mSensorName = name;
  mHwmonDir = discoverSensor();
  emit sensorNameChanged();
  poll();
}

int NativeHwmon::tempIndex() const { return mTempIndex; }

void NativeHwmon::setTempIndex(int index) {
  if (index == mTempIndex)
    return;
  mTempIndex = index;
  emit tempIndexChanged();
  poll();
}
