#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <semaphore>

int main(int argc, char** argv) {
    int numTasks = 100000;
    if (argc > 1) numTasks = std::stoi(argv[1]);
    std::atomic<int> remaining(numTasks);
    std::counting_semaphore<> sem(0);
    std::vector<std::thread> threads;
    threads.reserve(numTasks);
    for (int i = 0; i < numTasks; i++) {
        threads.emplace_back([] {
            std::this_thread::sleep_for(std::chrono::seconds(10));
        });
    }
    for (auto& t : threads) t.join();
    std::cout << "All tasks completed" << std::endl;
    return 0;
}
