#include <QApplication>
#include <VPApplication>

#include <QQmlApplicationEngine>
#include "qmlfileaccess.h"
#include <QtQml>
#include <QDebug>

int main(int argc, char *argv[])
{

    QApplication app(argc, argv);

    VPApplication vplay;

    // QQmlApplicationEngine is the preferred way to start qml projects since Qt 5.2
    // if you have older projects using Qt App wizards from previous QtCreator versions than 3.1, please change them to QQmlApplicationEngine
    QQmlApplicationEngine engine;
    vplay.initialize(&engine);

    qmlRegisterType<QMLFileAccess>("com.seawolf.qmlfileaccess", 1, 0, "QMLFileAccess");

    // use this during development
    // for PUBLISHING, use the entry point below
    vplay.setMainQmlFileName(QStringLiteral("qml/Main.qml"));

    // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
    // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
    // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
    // also see the .pro file for more details
    //  vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/Main.qml"));

    engine.load(QUrl(vplay.mainQmlFileName()));

    //Unit test of QMLFileAccess
//    QMLFileAccess qfa;
//    qDebug() << "Path = " << qfa.getAccessiblePath();
//    qDebug() << "Open=" << qfa.qmlOpenFile("TestQMLRWFile");
//    qDebug() << "Wrote = " << qfa.qmlWrite("TEST");
//    QString qstr;
//    qDebug() << "Read = " << qfa.qmlRead(qstr);
//    qDebug() << qstr;


    return app.exec();
}

