std::atomic<int> remaining;
std::counting_semaphore<> sem(0);

void worker() {
    std::this_thread::sleep_for(std::chrono::seconds(10));
    if (remaining.fetch_sub(1) == 1) {
        sem.release();
    }
}

int main(int argc, char** argv) {
    int numTasks = 100000;
    if (argc > 1) numTasks = std::stoi(argv[1]);
    remaining.store(numTasks);
    
    std::vector<std::thread> threads;
    threads.reserve(numTasks);
    for (int i = 0; i < numTasks; i++) {
        threads.emplace_back(worker);
    }
    for (auto& t : threads) t.join();
    sem.acquire();
    std::cout << "All tasks completed" << std::endl;
    return 0;
}
