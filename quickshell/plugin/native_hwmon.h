#pragma once

#include "native_sensor.h"
#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <string>

class NativeHwmon : public NativeSensor {
  Q_OBJECT
  QML_ELEMENT

  // Config properties are write-only in practice — no NOTIFY needed.
  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
  Q_PROPERTY(QString sensorName READ sensorName WRITE setSensorName)
  Q_PROPERTY(int tempIndex READ tempIndex WRITE setTempIndex)
  Q_PROPERTY(QString hwmonRoot READ hwmonRoot WRITE setHwmonRoot)

public:
  explicit NativeHwmon(QObject *parent = nullptr);

  // Getters
  [[nodiscard]] double temperature() const;
  [[nodiscard]] QString sensorName() const;
  [[nodiscard]] int tempIndex() const;
  [[nodiscard]] QString hwmonRoot() const;

  // Setters
  void setSensorName(const QString &name);
  void setTempIndex(int index);
  void setHwmonRoot(const QString &root);

signals:
  void temperatureChanged();

private:
  // Methods
  void poll() override;
  [[nodiscard]] std::string discoverSensor() const;

  // Configuration (writable via properties)
  QString mSensorName{"k10temp"};
  int mTempIndex{1};
  QString mHwmonRoot{"/sys/class/hwmon"};

  // Derived state
  double mTemperature{};
  std::string mHwmonDir; // resolved chip dir, from discoverSensor()
};
