extern "C" void step2(char *buf);

extern "C"
__attribute__((weak))
void step1(void) {
    char buf[100];
    step2(buf);
}
