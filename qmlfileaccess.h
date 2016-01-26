#ifndef QMLFILEACCESS_H
#define QMLFILEACCESS_H

#include <QObject>
#include <QFile>
#include <QString>

#include <QDataStream>

//! QML plugin that Read/Writes files on Android, Windows, Linux systems. IOS?
class QMLFileAccess : public QObject
{
    Q_OBJECT
public:
    explicit QMLFileAccess(QObject *parent = 0);
    virtual ~QMLFileAccess();
    QDataStream::Status qmlOpenFile(const QString FileName);
    QDataStream::Status qmlRead(QString &s);
    QDataStream::Status qmlWrite(QString s);
    virtual QString getAccessiblePath();
signals:

public slots:
protected:
private:
    QFile m_qfile;
    QString m_fileName;
    QString m_accessPath;
    QDataStream m_dataStream;
};

#endif // QMLFILEACCESS_H
