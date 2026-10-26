#include <QApplication>
#include <QLabel>

int main(int argc, char* argv[])
{
  QApplication app(argc, argv);
  QLabel label(QStringLiteral("Qt %1").arg(QLatin1String(qVersion())));
  label.show();
  return 0;
}
