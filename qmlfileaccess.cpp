#include "qmlfileaccess.h"
#include <QStandardPaths>
#include <QDir>
#include <QUrl>
#include <QDebug>
#include <QFile>

QMLFileAccess::QMLFileAccess(QObject *parent) : QObject(parent)
{
}
QMLFileAccess::~QMLFileAccess(){
    if (!m_qfile.isOpen()){
        m_qfile.close();
    }
}

bool QMLFileAccess::open(const QString fileName){
    m_fileName = fileName;
    m_qfile.setFileName(m_fileName);
    bool res = m_qfile.open(QIODevice::ReadWrite);
    m_dataStream.setDevice(&m_qfile);
    return res;
}

QString QMLFileAccess::close(){
    m_dataStream.unsetDevice();
    m_qfile.close();
   return m_qfile.errorString();
}

QString QMLFileAccess::read(){

    QString s;
    m_qfile.seek(0);
    m_dataStream >> s;
    return s;
}

QString QMLFileAccess::write(const QString s){
    m_qfile.seek(m_qfile.size());
    m_dataStream << s;
    return m_qfile.errorString();
}

QString QMLFileAccess::getAccessiblePath(const QString myDir){
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + myDir;
    QDir dir(path);
    if (!dir.exists())
    dir.mkpath(path);
    if (!path.isEmpty() && !path.endsWith("/"))
    path += "/";
    return path;
}
QString QMLFileAccess::urlToLocalFile(QString url){
    QUrl uf(url);
   return uf.toLocalFile();
}
bool QMLFileAccess::removeFile(const QString fileName){
    QFile qf;
    qf.setFileName(fileName);
    bool res = qf.remove();
    if (false == res){
        qDebug() << qf.errorString();
    }
    return res;
}
