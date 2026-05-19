#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

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
  double m_temperature{};
  QTimer m_timer{};

  void poll();
};
