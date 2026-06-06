#include "native_ram.h"
#include "native_sensor.h"

#include <QTimer>
#include <fstream>
#include <sstream>
#include <string>

NativeRam::NativeRam(QObject *parent) : NativeSensor(parent) {
  mTimer.setInterval(1000);
  poll();
  mTimer.start();
}

// ── Getters ──────────────────────────────────────────────────────────────

double NativeRam::ramPercent() const { return mRamPercent; }

double NativeRam::ramUsedKb() const { return mRamUsedKb; }

double NativeRam::ramTotalKb() const { return mMemTotal; }

double NativeRam::ramBuffersKb() const { return mBuffersKb; }

double NativeRam::ramCachedKb() const { return mCachedKb; }

double NativeRam::swapUsedKb() const { return mSwapUsedKb; }

double NativeRam::swapTotalKb() const { return mSwapTotalKb; }

// ── Internals ──────────────────────────────────────────────────────────────

void NativeRam::poll() {
  const auto oldPercent = mRamPercent;
  const auto oldUsedKb = mRamUsedKb;
  const auto oldMemTotal = mMemTotal;
  const auto oldAvailable = mMemAvailable;
  const auto oldBuffersKb = mBuffersKb;
  const auto oldCachedKb = mCachedKb;
  const auto oldSwapUsedKb = mSwapUsedKb;

  parseMemInfo();

  if (oldPercent != mRamPercent || oldUsedKb != mRamUsedKb ||
      oldMemTotal != mMemTotal || oldAvailable != mMemAvailable ||
      oldBuffersKb != mBuffersKb || oldCachedKb != mCachedKb ||
      oldSwapUsedKb != mSwapUsedKb) {
    emit ramChanged();
  }
}

void NativeRam::parseMemInfo() {
  std::ifstream iss("/proc/meminfo");
  std::string line;
  while (std::getline(iss, line)) {
    std::string key, unit;
    uint64_t value;
    std::istringstream issLine(line);
    issLine >> key >> value >> unit;
    if (key == "MemTotal:")
      mMemTotal = value;
    else if (key == "MemAvailable:")
      mMemAvailable = value;
    else if (key == "Buffers:")
      mBuffersKb = value;
    else if (key == "Cached:")
      mCachedKb = value;
    else if (key == "SwapTotal:")
      mSwapTotalKb = value;
    else if (key == "SwapFree:")
      mSwapFreeKb = value;
  }
  mRamUsedKb = mMemTotal - mMemAvailable;
  mSwapUsedKb = mSwapTotalKb - mSwapFreeKb;
  if (mMemTotal > 0)
    mRamPercent = static_cast<double>(mRamUsedKb) / mMemTotal * 100;
}
