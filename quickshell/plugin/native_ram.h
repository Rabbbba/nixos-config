#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <string>

#include "native_sensor.h"

class NativeRam : public NativeSensor {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(double ramPercent READ ramPercent NOTIFY ramChanged)
  Q_PROPERTY(double ramUsedKb READ ramUsedKb NOTIFY ramChanged)
  Q_PROPERTY(double ramTotalKb READ ramTotalKb NOTIFY ramChanged)
  Q_PROPERTY(double ramBuffersKb READ ramBuffersKb NOTIFY ramChanged)
  Q_PROPERTY(double ramCachedKb READ ramCachedKb NOTIFY ramChanged)
  Q_PROPERTY(double swapUsedKb READ swapUsedKb NOTIFY ramChanged)
  Q_PROPERTY(double swapTotalKb READ swapTotalKb NOTIFY ramChanged)

public:
  explicit NativeRam(QObject *parent = nullptr);

  // Getters
  [[nodiscard]] double ramPercent() const;
  [[nodiscard]] double ramUsedKb() const;
  [[nodiscard]] double ramTotalKb() const;
  [[nodiscard]] double ramBuffersKb() const;
  [[nodiscard]] double ramCachedKb() const;
  [[nodiscard]] double swapUsedKb() const;
  [[nodiscard]] double swapTotalKb() const;

signals:
  void ramChanged();

private:
  // Methods
  void poll() override;                // parse /proc/meminfo, emit ramChanged
  void parseMemInfo();                 // raw parsing from /proc/meminfo

  // Raw values from /proc/meminfo (in kB)
  double mMemTotal{};
  double mMemAvailable{};
  double mBuffersKb{};       // memory used by buffers
  double mCachedKb{};        // memory used by page cache
  double mSwapTotalKb{};      // total swap space
  double mSwapFreeKb{};        // unused swap space

  // Derived state (exposed via properties)
  double mRamPercent{};      // (MemTotal - MemAvailable) / MemTotal
  double mRamUsedKb{};       // MemTotal - MemAvailable
  double mSwapUsedKb{};      // SwapTotal - SwapFree
};
