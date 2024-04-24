extern "C" void step2(char *buf);

extern "C" void otherFunc(void);

extern "C"
void step1(void) {
    otherFunc();
    char buf[100];
    step2(buf);
}
