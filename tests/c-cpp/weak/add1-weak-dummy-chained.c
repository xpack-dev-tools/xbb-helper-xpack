extern int value;
__attribute__((weak)) void func(void) {
    value += 1;
}
void dummy(void) {
    func();
}
