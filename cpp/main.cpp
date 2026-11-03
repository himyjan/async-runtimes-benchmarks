// C++ benchmark — std::jthread (C++20) pool over a shared deadline table.
//
// All 100k tasks are registered from t=0 with the same absolute deadline
// (start + 10s). 1000 jthreads claim tasks and sleep_until() each task's
// deadline — the first wait blocks until t+10s, later waits return
// immediately (timer aggregation for identical expiries).
#include <atomic>
#include <chrono>
#include <iostream>
#include <thread>
#include <vector>

#define NUM_THREADS 1000

int main(int argc, char* argv[]) {
    int num_tasks = 100000;
    if (argc > 1) {
        num_tasks = std::stoi(argv[1]);
    }

    using clk = std::chrono::steady_clock;
    const auto deadline = clk::now() + std::chrono::seconds(10);

    // Task table: every task pending from t=0, due at start + 10s.
    std::vector<clk::time_point> tasks(num_tasks, deadline);

    std::atomic<int> next_task{0};
    std::vector<std::jthread> threads;
    threads.reserve(NUM_THREADS);

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back([&]() {
            for (;;) {
                int idx = next_task.fetch_add(1, std::memory_order_relaxed);
                if (idx >= num_tasks) break;
                std::this_thread::sleep_until(tasks[idx]);
            }
        });
    }
    for (auto& t : threads) t.join();

    std::cout << "All tasks completed" << std::endl;
    return 0;
}
