#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <string>

class NativeHwmon : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)

public:
  explicit NativeHwmon(QObject *parent = nullptr);
  double temperature() const;

signals:
  void temperatureChanged();

private:
  double mTemperature{};
  QTimer mTimer{};
  std::string mSensorPath{};
  std::string discoverSensor() const;

  void poll();
};
