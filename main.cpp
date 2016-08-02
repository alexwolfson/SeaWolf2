#include <QtWidgets/QApplication>
//#include <VPApplication>

#include <QQmlApplicationEngine>
#include <QApplication>
#include "qmlfileaccess.h"
#include <QtQml>
#include <QDebug>
#include <QtCore/QLoggingCategory>
#include <QQmlContext>
#include <QGuiApplication>
#include <QQuickView>
#include "heartrate.h"

int main(int argc, char *argv[])
{

    QApplication app(argc, argv);

    //VPApplication vplay;

    // QQmlApplicationEngine is the preferred way to start qml projects since Qt 5.2
    // if you have older projects using Qt App wizards from previous QtCreator versions than 3.1, please change them to QQmlApplicationEngine
    QQmlApplicationEngine engine;
    //vplay.initialize(&engine);
    HeartRate heartRate;
    QMLFileAccess qfa;
    QQmlContext * myContext = engine.rootContext();
    myContext->setContextProperty("heartRate", &heartRate);
    myContext->setContextProperty("qfa", &qfa);
    //qmlRegisterType<QMLFileAccess>("com.seawolf.qmlfileaccess", 1, 0, "QMLFileAccess");
    //Unit test of QMLFileAccess
    qDebug() << "Path = " << qfa.getAccessiblePath("test_qfa");
    qDebug() << "Open=" << qfa.open("TestQMLRWFile");
    qDebug() << "Wrote = " << qfa.write("TEST");
    qDebug() << "Close = " << qfa.close();
    qDebug() << "Open=" << qfa.open("TestQMLRWFile");
    qDebug() << "Read = " << qfa.read();
    qDebug() << "Close = " << qfa.close();
    qDebug() << "Delete = " << qfa.removeFile("TestQMLRWFile");
//    //qDebug() << qstr;

    // use this during development
    // for PUBLISHING, use the entry point below
    //vplay.setMainQmlFileName(QStringLiteral("qml/Main.qml"));

    // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
    // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
    // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
    // also see the .pro file for more details
    //  vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/Main.qml"));

    engine.load(QUrl("qrc:/qml/Main.qml"));
    return app.exec();
}

