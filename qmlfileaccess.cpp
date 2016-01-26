#include "qmlfileaccess.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

QMLFileAccess::QMLFileAccess(QObject *parent) : QObject(parent)
{

}
QMLFileAccess::~QMLFileAccess(){
    if (!m_qfile.isOpen()){
        m_qfile.close();
    }
}

QDataStream::Status QMLFileAccess::qmlOpenFile(const QString fileName){
    m_fileName = fileName;
    m_qfile.setFileName(getAccessiblePath() + m_fileName);
    m_qfile.open(QIODevice::ReadWrite);
    m_dataStream.setDevice(&m_qfile);
    return m_dataStream.status();
}

QDataStream::Status QMLFileAccess::qmlRead(QString &s){
    m_qfile.seek(0);
    m_dataStream >> s;
    return m_dataStream.status();
}

QDataStream::Status QMLFileAccess::qmlWrite(const QString s){
    m_qfile.seek(m_qfile.size());
    m_dataStream << s;
    return m_dataStream.status();
}

QString QMLFileAccess::getAccessiblePath(){
    QString path = QStandardPaths::standardLocations(QStandardPaths::DataLocation).value(0);
    QDir dir(path);
    if (!dir.exists())
    dir.mkpath(path);
    if (!path.isEmpty() && !path.endsWith("/"))
    path += "/";
    return path;

}
/*
const  QString fileName = path+"abc.txt";
qDebug()<<fileName;
QFile tf(fileName);
tf.open(QIODevice::ReadWrite);
tf.write("TEST");
QString testString;
tf.read(testString, 25);
tf.close();
if(QFile::exists(fileName))
    qDebug()<<"abc.txt exists";
else
    qDebug()<<"abc.txt doesnt exists";
*/
