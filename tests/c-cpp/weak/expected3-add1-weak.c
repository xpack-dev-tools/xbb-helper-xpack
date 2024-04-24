int expected = 3;
extern int value;
__attribute__((weak)) void func(void) {
    value += 1;
}
