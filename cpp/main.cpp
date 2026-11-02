#include <chrono>
#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <mutex>
#include <condition_variable>

#define NUM_THREADS 1000

int main(int argc, char* argv[]) {
    int num_tasks = 100000;
    if (argc > 1) {
        num_tasks = std::stoi(argv[1]);
    }

    std::atomic<int> remaining(num_tasks);
    std::atomic<int> next_task(0);
    std::mutex mtx;
    std::condition_variable cv;
    bool done = false;

    auto worker = [&]() {
        while (true) {
            int i = next_task.fetch_add(1);
            if (i >= num_tasks) break;
            std::this_thread::sleep_for(std::chrono::seconds(10));
            remaining.fetch_sub(1);
        }
    };

    std::vector<std::jthread> threads;
    threads.reserve(NUM_THREADS);
    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(worker);
    }

    for (auto& t : threads) {
        t.join();
    }

    std::cout << "All tasks completed" << std::endl;
    return 0;
}
