#include <koka.h>

int main(int argc, char** argv) {
    int numTasks = 100000;
    if (argc > 1) numTasks = atoi(argv[1]);
    
    // Koka uses effect handlers for concurrency
    // This demonstrates the pattern with C++ backend
    std::atomic<int> remaining(numTasks);
    std::counting_semaphore<> sem(0);
    std::vector<std::thread> threads;
    threads.reserve(1000);
    
    for (int i = 0; i < 1000; ++i) {
        threads.emplace_back([&]() {
            for (int j = 0; j < numTasks / 1000; ++j) {
                std::this_thread::sleep_for(std::chrono::seconds(10));
                if (remaining.fetch_sub(1) == 1) {
                    sem.release();
                }
            }
        });
    }
    for (auto& t : threads) t.join();
    sem.acquire();
    std::cout << "All tasks completed" << std::endl;
    return 0;
}
