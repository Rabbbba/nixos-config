#include "native_network.h"
#include "native_sensor.h"

#include <QTimer>
#include <cstdint>
#include <fstream>
#include <sstream>
#include <string>
#include <utility>

NativeNetwork::NativeNetwork(QObject *parent) : NativeSensor(parent) {
  mTimer.setInterval(2000);
  poll(); // NOLINT(clang-analyzer-optin.cplusplus.VirtualCall)
  mTimer.start();
}

NativeNetwork::NativeNetwork(std::string procRoot, std::string sysRoot,
                             QObject *parent)
    : NativeSensor(parent), mProcRoot(std::move(procRoot)),
      mSysRoot(std::move(sysRoot)) {
  mTimer.setInterval(2000);
  poll(); // NOLINT(clang-analyzer-optin.cplusplus.VirtualCall)
  mTimer.start();
}

void NativeNetwork::refresh() { poll(); }

// ── Getters ──────────────────────────────────────────────────────────────

double NativeNetwork::downloadKbps() const { return mDownloadKbps; }

double NativeNetwork::uploadKbps() const { return mUploadKbps; }

// ── Internals ──────────────────────────────────────────────────────────────

void NativeNetwork::poll() {
  std::string iface = discoverNetwork();
  if (iface.empty()) {
    return;
  }

  uint64_t rx{};
  std::ifstream rxFile(mSysRoot + "/class/net/" + iface +
                       "/statistics/rx_bytes");
  rxFile >> rx;
  uint64_t tx{};
  std::ifstream txFile(mSysRoot + "/class/net/" + iface +
                       "/statistics/tx_bytes");
  txFile >> tx;

  // First poll only seeds the previous-tick counters; no delta yet.
  if (!mPrimed) {
    mPrevRx = rx;
    mPrevTx = tx;
    mPrimed = true;
    return;
  }

  // Counters reset on interface change → unsigned subtraction would wrap.
  // Re-seed and skip this tick rather than emit a bogus spike.
  if (rx < mPrevRx || tx < mPrevTx) {
    mPrevRx = rx;
    mPrevTx = tx;
    return;
  }

  uint64_t deltaRx{rx - mPrevRx};
  double download{static_cast<double>(deltaRx) / mTimer.interval() * 1000.0 /
                  1024.0};
  if (download != mDownloadKbps) {
    mDownloadKbps = download;
    emit downloadKbpsChanged();
  }

  uint64_t deltaTx{tx - mPrevTx};
  double upload{static_cast<double>(deltaTx) / mTimer.interval() * 1000.0 /
                1024.0};
  if (upload != mUploadKbps) {
    mUploadKbps = upload;
    emit uploadKbpsChanged();
  }

  mPrevRx = rx;
  mPrevTx = tx;
}

std::string NativeNetwork::discoverNetwork() const {
  std::ifstream file(mProcRoot + "/net/route");
  std::string line;
  std::getline(file, line); // skip the header row
  while (std::getline(file, line)) {
    std::string iface;
    std::string destination;
    std::istringstream iss(line);
    iss >> iface >> destination;
    // Default route: destination 0.0.0.0 ("00000000") → its iface is routable.
    if (destination == "00000000") {
      return iface;
    }
  }
  return {};
}
