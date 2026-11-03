#include <iostream>
#include <thread>
#include <vector>
#include <chrono>

int main(int argc, char* argv[]) {
    int num_tasks = 100000;
    if (argc > 1) {
        num_tasks = std::stoi(argv[1]);
    }

    std::cout << "Spawning " << num_tasks << " concurrent tasks..." << std::endl;

    std::vector<std::jthread> threads;
    threads.reserve(static_cast<size_t>(num_tasks));

    for (int i = 0; i < num_tasks; ++i) {
        threads.emplace_back([] {
            std::this_thread::sleep_for(std::chrono::seconds(10));
        });
    }

    std::cout << "All tasks completed" << std::endl;
    return 0;
}
