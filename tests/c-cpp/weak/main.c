#include <stdio.h>

void func(void);
void dummy(void);

int value = 1;
extern int expected;

int main(int argc, char **argv) {
    func();
    dummy();
    if (value != expected) {
        printf("expected %d, got %d\n", expected, value);
        return 1;
    }
    return 0;
}

