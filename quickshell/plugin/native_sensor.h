#pragma once

#include <QObject>
#include <QTimer>

class NativeSensor : public QObject {
  Q_OBJECT

protected:
  QTimer mTimer;

  explicit NativeSensor(QObject *parent = nullptr);

public:
  ~NativeSensor() override = default;
  virtual void poll() = 0;
};
