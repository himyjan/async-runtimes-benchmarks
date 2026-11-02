#include <QCoreApplication>
#include <QThread>
#include <QWaitCondition>
#include <QMutex>
#include <QDebug>
#include <atomic>

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    int numTasks = 100000;
    if (argc > 1) numTasks = QString(argv[1]).toInt();
    std::atomic<int> remaining(numTasks);
    QWaitCondition sem;
    QMutex mutex;
    
    QVector<QThread*> threads;
    threads.reserve(numTasks);
    for (int i = 0; i < numTasks; i++) {
        QThread *t = new QThread();
        QObject::connect(t, &QThread::started, [&]() {
            QThread::sleep(10);
            if (remaining.fetch_sub(1) == 1) {
                sem.wakeAll();
            }
        });
        threads.append(t);
        t->start();
    }
    
    mutex.lock();
    sem.wait(&mutex);
    mutex.unlock();
    
    qDebug() << "All tasks completed";
    return 0;
}
