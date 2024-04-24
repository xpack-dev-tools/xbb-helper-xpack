extern "C" void step2(char *buf);
extern "C" void abort(void);

extern "C"
__attribute__((weak))
void step1(void) {
    abort();
}

extern "C" void otherFunc(void) {
}
