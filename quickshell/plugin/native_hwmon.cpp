#include "native_hwmon.h"

#include <QDebug>
#include <QTimer>
#include <filesystem>
#include <fstream>
#include <string>

NativeHwmon::NativeHwmon(QObject *parent) : QObject(parent) {
  mTimer.setInterval(2000);
  connect(&mTimer, &QTimer::timeout, this, &NativeHwmon::poll);
  mHwmonDir = discoverSensor();
  poll();
  mTimer.start();
}

// ── Getters ──────────────────────────────────────────────────────────────

double NativeHwmon::temperature() const { return mTemperature; }

QString NativeHwmon::sensorName() const { return mSensorName; }

int NativeHwmon::tempIndex() const { return mTempIndex; }

QString NativeHwmon::hwmonRoot() const { return mHwmonRoot; }

// ── Setters ──────────────────────────────────────────────────────────────

void NativeHwmon::setSensorName(const QString &name) {
  if (name == mSensorName)
    return;
  mSensorName = name;
  mHwmonDir = discoverSensor(); // chip changed → rescan
  emit sensorNameChanged();
  poll();
}

void NativeHwmon::setTempIndex(int index) {
  if (index == mTempIndex)
    return;
  mTempIndex = index;
  emit tempIndexChanged();
  poll(); // same chip, only the file changes → no rescan
}

void NativeHwmon::setHwmonRoot(const QString &root) {
  if (root == mHwmonRoot)
    return;
  mHwmonRoot = root;
  mHwmonDir = discoverSensor(); // search root changed → rescan
  emit hwmonRootChanged();
  poll();
}

// ── Internals ────────────────────────────────────────────────────────────

void NativeHwmon::poll() {
  if (mHwmonDir.empty())
    return;
  std::ifstream file{mHwmonDir + "/temp" + std::to_string(mTempIndex) +
                     "_input"};
  double newValue{};
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
       std::filesystem::directory_iterator{mHwmonRoot.toStdString()}) {
    std::filesystem::path path = element.path() / "name";
    std::ifstream file{path};
    std::string name;
    if (!(file >> name))
      continue;
    if (name != mSensorName.toStdString())
      continue;
    return element.path().string();
  }
  qWarning() << "NativeHwmon: no hwmon matched sensor name" << mSensorName;
  return {};
}
