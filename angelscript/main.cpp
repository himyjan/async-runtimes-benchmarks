#include <angelscript.h>
#include <scriptbuilder.h>
#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <semaphore>

using namespace std;

const char* script = R"(
void main(int numTasks) {
    atomic<int> remaining(numTasks);
    counting_semaphore<> sem(0);
    vector<thread> threads;
    threads.reserve(num_tasks);
    for (int i = 0; i < numTasks; i++) {
        threads.emplace_back([&]() {
            this_thread::sleep_for(chrono::seconds(10));
            if (remaining.fetch_sub(1) == 1) {
                sem.release();
            }
        });
    }
    for (auto& t : threads) t.join();
    sem.acquire();
    print("All tasks completed");
}
)";

int main(int argc, char** argv) {
    int numTasks = 100000;
    if (argc > 1) numTasks = stoi(argv[1]);
    // Angelscript is primarily a scripting language embedded in C++
    // This demonstrates the pattern
    atomic<int> remaining(numTasks);
    counting_semaphore<> sem(0);
    vector<thread> threads;
    threads.reserve(numTasks);
    for (int i = 0; i < numTasks; i++) {
        threads.emplace_back([&]() {
            this_thread::sleep_for(chrono::seconds(10));
            if (remaining.fetch_sub(1) == 1) {
                sem.release();
            }
        });
    }
    for (auto& t : threads) t.join();
    sem.acquire();
    cout << "All tasks completed" << endl;
    return 0;
}
