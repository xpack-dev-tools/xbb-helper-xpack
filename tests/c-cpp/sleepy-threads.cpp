#include <thread>
#include <iostream>
#include <vector>
#include <chrono>
#include <cassert>

char letters[] = "abcdefghijklmnopqrstuvwxyz";

void doSomething(int id) {
    std::this_thread::sleep_for (std::chrono::milliseconds(id*4));
    std::cout << letters[id] ;
}

/*
 * Spawns n threads
 */
void spawnThreads(int n)
{
    std::vector<std::thread> threads(n);

    // spawn n threads:
    for (int i = 0; i < n; i++) {
        threads[i] = std::thread(doSomething, i);
    }

    for (auto& th : threads) {
        th.join();
    }
}

// The result should be an ordered list of letters.
int main(int argc, char* argv[])
{
    if (argc < 2) {
        std::cout << "Usage: sleepy-thread N" << std::endl;
        exit(1);
    }

    int n = atoi(argv[1]);
    assert(n < sizeof(letters));

    spawnThreads(n);
    std::cout << std::endl;
}
