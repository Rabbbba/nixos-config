#include "native_sensor.h"

#include <QObject>

NativeSensor::NativeSensor(QObject *parent) : QObject(parent) {
  connect(&mTimer, &QTimer::timeout, this, &NativeSensor::poll);
}
