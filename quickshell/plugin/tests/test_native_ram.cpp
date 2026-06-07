#include <QtTest/QtTest>

#include <string>

#include "../native_ram.h"

#ifndef TEST_FIXTURE_PROC_ROOT
#error "TEST_FIXTURE_PROC_ROOT must be defined by CMake"
#endif

class TestNativeRam : public QObject {
  Q_OBJECT

private slots:
  void parsesMeminfoAndComputesUsage();
};

void TestNativeRam::parsesMeminfoAndComputesUsage() {
  NativeRam ram{std::string{TEST_FIXTURE_PROC_ROOT}};

  QCOMPARE(ram.ramTotalKb(), 1000.0);
  QCOMPARE(ram.ramUsedKb(), 750.0);
  QVERIFY(qAbs(ram.ramPercent() - 75.0) < 0.001);
  QCOMPARE(ram.ramBuffersKb(), 50.0);
  QCOMPARE(ram.ramCachedKb(), 100.0);
  QCOMPARE(ram.swapTotalKb(), 400.0);
  QCOMPARE(ram.swapUsedKb(), 250.0);
}

QTEST_MAIN(TestNativeRam)
#include "test_native_ram.moc"
