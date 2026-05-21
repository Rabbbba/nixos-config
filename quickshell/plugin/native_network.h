#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <cstdint>
#include <string>

class NativeNetwork : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(double downloadKbps READ downloadKbps NOTIFY downloadKbpsChanged)
  Q_PROPERTY(double uploadKbps READ uploadKbps NOTIFY uploadKbpsChanged)

public:
  explicit NativeNetwork(QObject *parent = nullptr);

  // Getters
  double downloadKbps() const;
  double uploadKbps() const;

signals:
  void downloadKbpsChanged();
  void uploadKbpsChanged();

private:
  // Methods
  void poll();                         // read counters, compute speed, emit
  std::string discoverNetwork() const; // active iface from the default route

  // Cumulative rx/tx byte counters from the previous tick, for delta computation.
  uint64_t mPrevRx{};
  uint64_t mPrevTx{};
  // False until the first poll seeds mPrev*; guards against a bogus first delta.
  bool mPrimed{};

  // Derived speeds in KiB/s, exposed via the read-only properties.
  double mDownloadKbps{};
  double mUploadKbps{};

  QTimer mTimer{}; // poll heartbeat
};
