#include <QtTest/QtTest>

#include <QDir>
#include <QFile>
#include <QTemporaryDir>
#include <string>

#include "../native_network.h"

#ifndef TEST_FIXTURE_NETWORK_ROOT
#error "TEST_FIXTURE_NETWORK_ROOT must be defined by CMake"
#endif

namespace {

void copyFixtureFile(const QString &sourcePath, const QString &targetPath) {
  QFile::remove(targetPath);
  QVERIFY(QFile::copy(sourcePath, targetPath));
}

void writeTextFile(const QString &path, const QByteArray &content) {
  QFile file{path};
  QVERIFY(file.open(QIODevice::WriteOnly | QIODevice::Truncate));
  QCOMPARE(file.write(content), static_cast<qint64>(content.size()));
}

} // namespace

class TestNativeNetwork : public QObject {
  Q_OBJECT

private slots:
  void computesThroughputFromCounterDeltas();
};

void TestNativeNetwork::computesThroughputFromCounterDeltas() {
  QTemporaryDir tempDir;
  QVERIFY(tempDir.isValid());

  const QString procRoot{tempDir.path() + "/proc"};
  const QString sysRoot{tempDir.path() + "/sys"};
  const QString statsRoot{sysRoot + "/class/net/enp1s0/statistics"};

  QDir dir;
  QVERIFY(dir.mkpath(procRoot + "/net"));
  QVERIFY(dir.mkpath(statsRoot));

  const QString fixtureRoot{QString::fromUtf8(TEST_FIXTURE_NETWORK_ROOT)};
  copyFixtureFile(fixtureRoot + "/proc/net/route", procRoot + "/net/route");
  copyFixtureFile(fixtureRoot + "/sys/class/net/enp1s0/statistics/rx_bytes",
                  statsRoot + "/rx_bytes");
  copyFixtureFile(fixtureRoot + "/sys/class/net/enp1s0/statistics/tx_bytes",
                  statsRoot + "/tx_bytes");

  NativeNetwork network{procRoot.toStdString(), sysRoot.toStdString()};

  QCOMPARE(network.downloadKbps(), 0.0);
  QCOMPARE(network.uploadKbps(), 0.0);

  writeTextFile(statsRoot + "/rx_bytes", "3048\n");
  writeTextFile(statsRoot + "/tx_bytes", "2548\n");

  network.refresh();

  QVERIFY(qAbs(network.downloadKbps() - 1.0) < 0.001);
  QVERIFY(qAbs(network.uploadKbps() - 1.0) < 0.001);
}

QTEST_MAIN(TestNativeNetwork)
#include "test_native_network.moc"
