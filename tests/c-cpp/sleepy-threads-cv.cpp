#include <thread>
#include <iostream>
#include <vector>
#include <chrono>
#include <cassert>
#include <condition_variable>

char letters[] = "abcdefghijklmnopqrstuvwxyz";

std::condition_variable cv;
std::mutex cv_m;

// Global counter, increased by each thread, in order.
int counter = -1;

// Each thread will wait for the counter to reach its id, print a letter,
// increase the counter, notify the remaining threads and terminate.
void doSomething(int id)
{
    // Wait for the counter to reach this thread.
    std::unique_lock<std::mutex> lk(cv_m);
    cv.wait(lk, [&]{ return counter == id; });

    // Print a single letter.
    std::cout << letters[id];

    // Spend some time.
    std::this_thread::sleep_for (std::chrono::milliseconds(10));

    // Proceed to the next thread.
    counter++;

    cv.notify_all();

    // Return, the thread is done.
}

/*
 * Spawns n threads
 */
void spawnThreads(int n)
{
    std::vector<std::thread> threads(n);

    // Spawn n threads; all will block on the condition variable.
    for (int i = 0; i < n; i++) {
        threads[i] = std::thread(doSomething, i);
    }

    // Initiate the first thread (id=0).
    counter++;
    cv.notify_all();

    // Wait the counter to reach the upper limit.
    std::unique_lock<std::mutex> lk(cv_m);
    cv.wait(lk, [&]{ return counter == n; });

    // All threads should be completed by now.
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
