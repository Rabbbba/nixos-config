#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <string>

class NativeHwmon : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
  Q_PROPERTY(QString sensorName READ sensorName WRITE setSensorName NOTIFY
                 sensorNameChanged)

public:
  explicit NativeHwmon(QObject *parent = nullptr);
  double temperature() const;
  QString sensorName() const;
  void setSensorName(const QString &name);

signals:
  void temperatureChanged();
  void sensorNameChanged();

private:
  double mTemperature{};
  QTimer mTimer{};
  QString mSensorName{"k10temp"};
  std::string mSensorPath{};
  std::string discoverSensor() const;

  void poll();
};
