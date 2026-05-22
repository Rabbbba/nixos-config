#pragma once

#include <QObject>
#include <QTimer>

class NativeSensor : public QObject {
  Q_OBJECT

protected:
  QTimer mTimer;

  explicit NativeSensor(QObject *parent = nullptr);

public:
  virtual ~NativeSensor() = default;
  virtual void poll() = 0;
};
