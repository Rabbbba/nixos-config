#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>
#include <string>

class NativeHwmon : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
  Q_PROPERTY(QString sensorName READ sensorName WRITE setSensorName NOTIFY
                 sensorNameChanged)
  Q_PROPERTY(
      int tempIndex READ tempIndex WRITE setTempIndex NOTIFY tempIndexChanged)

public:
  explicit NativeHwmon(QObject *parent = nullptr);
  double temperature() const;
  QString sensorName() const;
  void setSensorName(const QString &name);
  int tempIndex() const;
  void setTempIndex(int index);

signals:
  void temperatureChanged();
  void sensorNameChanged();
  void tempIndexChanged();

private:
  double mTemperature{};
  QTimer mTimer{};
  QString mSensorName{"k10temp"};
  std::string mHwmonDir{};
  std::string discoverSensor() const;
  int mTempIndex{1};

  void poll();
};
