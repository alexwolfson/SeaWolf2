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
    //typedef QDataStream::Status QMLFileStatus;
    enum QMLFileStatus {
        Ok = 0,
        ReadPastEnd,
        ReadCorruptData,
        WriteFailed
    };

    Q_ENUMS(QMLFileStatus)
    Q_INVOKABLE bool qmlOpenFile(const QString FileName);
    Q_INVOKABLE QString qmlCloseFile();
    Q_INVOKABLE QString qmlRead();
    Q_INVOKABLE QString qmlWrite(QString s);
    Q_INVOKABLE QString qmlToLocalFile(QString url);
    //! \param myDir subdirectory of the Accessible path. It will be created
    Q_INVOKABLE virtual QString getAccessiblePath(const QString myDir);
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

