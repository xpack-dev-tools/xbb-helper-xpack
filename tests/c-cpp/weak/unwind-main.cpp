#include <stdio.h>

extern "C" void step2(char *buf) {
    throw int(3);
}

extern "C"
void step1(void);

int main(int argc, char* argv[]) {
    int ret = 1;
    try {
        step1();
    } catch (int& e) {
        ret = 3 - e;
    }
    return ret;
}
