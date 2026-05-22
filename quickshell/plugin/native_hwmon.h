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

  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
  Q_PROPERTY(QString sensorName READ sensorName WRITE setSensorName NOTIFY
                 sensorNameChanged)
  Q_PROPERTY(
      int tempIndex READ tempIndex WRITE setTempIndex NOTIFY tempIndexChanged)
  Q_PROPERTY(QString hwmonRoot READ hwmonRoot WRITE setHwmonRoot NOTIFY
                 hwmonRootChanged)

public:
  explicit NativeHwmon(QObject *parent = nullptr);

  // Getters
  double temperature() const;
  QString sensorName() const;
  int tempIndex() const;
  QString hwmonRoot() const;

  // Setters
  void setSensorName(const QString &name);
  void setTempIndex(int index);
  void setHwmonRoot(const QString &root);

signals:
  void temperatureChanged();
  void sensorNameChanged();
  void tempIndexChanged();
  void hwmonRootChanged();

private:
  // Methods
  void poll() override;
  std::string discoverSensor() const;

  // Configuration (writable via properties)
  QString mSensorName{"k10temp"};
  int mTempIndex{1};
  QString mHwmonRoot{"/sys/class/hwmon"};

  // Derived state
  double mTemperature{};
  std::string mHwmonDir{}; // resolved chip dir, from discoverSensor()
};
