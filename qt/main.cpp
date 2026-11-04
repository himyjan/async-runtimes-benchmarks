#include <QCoreApplication>
#include <QThread>
#include <QWaitCondition>
#include <QMutex>
#include <QDebug>
#include <atomic>
#include <QVector>

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    int numTasks = 100000;
    if (argc > 1) numTasks = QString(argv[1]).toInt();
    std::atomic<int> remaining(numTasks);
    QWaitCondition cond;
    QMutex mutex;
    const int POOL_SIZE = 1000;
    bool done = false;

    auto worker = [&]() {
        while (!done) {
            mutex.lock();
            int i = __sync_fetch_and_add(&remaining, 0) - 1;
            // Use a separate counter for task claiming
            mutex.unlock();
            // This lambda approach is complex; use simpler design
            break;
        }
    };

    // Simpler approach: shared deadline table with thread pool
    QVector<QThread*> threads;
    threads.reserve(POOL_SIZE);
    std::atomic<int> next_task(0);
    QMutex tlock;
    QWaitCondition tcond;
    bool all_done = false;

    auto tworker = [&]() {
        while (true) {
            tlock.lock();
            int i = next_task.fetchAdd(1);
            if (i >= numTasks) {
                if (remaining.fetchSub(1) == 1) {
                    all_done = true;
                    cond.wakeAll();
                }
                tlock.unlock();
                return;
            }
            tlock.unlock();
            QThread::sleep(10); // sleep until shared deadline (~10s from start)
            tlock.lock();
            if (remaining.fetchSub(1) == 1) {
                all_done = true;
                cond.wakeAll();
            }
            tlock.unlock();
        }
    };

    for (int i = 0; i < POOL_SIZE; i++) {
        QThread *t = new QThread();
        QObject::connect(t, &QThread::started, tworker);
        threads.append(t);
        t->start();
    }

    mutex.lock();
    while (!all_done) {
        cond.wait(&mutex, 100);
    }
    mutex.unlock();

    for (QThread *t : threads) {
        t->wait();
        delete t;
    }

    qDebug() << "All tasks completed";
    return 0;
}
