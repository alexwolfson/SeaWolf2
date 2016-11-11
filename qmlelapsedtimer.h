//elapsed timer from
//  http://stackoverflow.com/questions/30997134/measuring-elapsed-time-in-qml
#ifndef ELAPSEDTIMER_H
#define ELAPSEDTIMER_H
#include <QObject>
#include <QElapsedTimer>

class QMLElapsedTimer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int elapsed MEMBER m_elapsed NOTIFY elapsedChanged)
    Q_PROPERTY(bool running MEMBER m_running NOTIFY runningChanged)
private:
    QElapsedTimer m_timer;
    int m_elapsed;
    bool m_running;
public slots:
    void start() {
        this->m_elapsed = 0;
        this->m_running = true;

        m_timer.start();
        emit runningChanged();
    }

    void stop() {
        this->m_elapsed = m_timer.elapsed();
        this->m_running = false;

        emit elapsedChanged();
        emit runningChanged();
    }

signals:
    void runningChanged();
    void elapsedChanged();
};
#endif // ELAPSEDTIMER_H
