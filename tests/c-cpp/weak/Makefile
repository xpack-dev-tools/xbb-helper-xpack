
EXEEXT = .exe

TARGETS = normal$(EXEEXT) weak-undef$(EXEEXT) weak-defined$(EXEEXT) weak-use$(EXEEXT) weak-override$(EXEEXT) weak-duplicate$(EXEEXT) overload-new$(EXEEXT) unwind-strong$(EXEEXT) unwind-weak$(EXEEXT)

all: $(TARGETS)

normal$(EXEEXT): main.o add2.o expected3.o dummy.o
	$(CC) -o $@ $+

weak-undef$(EXEEXT): main-weak.o expected1.o dummy.o
	$(CC) -o $@ $+

weak-defined$(EXEEXT): main-weak.o add2.o expected3.o dummy.o
	$(CC) -o $@ $+

weak-use$(EXEEXT): main.o add1-weak-dummy-chained.o expected3.o
	$(CC) -o $@ $+

weak-override$(EXEEXT): main.o add1-weak-dummy-chained.o add2.o expected5.o
	$(CC) -o $@ $+

weak-duplicate$(EXEEXT): main.o add1-weak-dummy-chained.o expected3-add1-weak.o
	$(CC) -o $@ $+

overload-new$(EXEEXT): overload-new.o
	$(CXX) -o $@ $+ -static

unwind-weak$(EXEEXT): unwind-weak.o unwind-main.o
	$(CXX) -o $@ $+ -static

unwind-strong$(EXEEXT): unwind-weak-dummy.o unwind-main.o unwind-strong.o
	$(CXX) -o $@ $+ -static

test: all
	for i in $(TARGETS); do \
	    echo $$i; \
	    $(EXEC) ./$$i || exit 1; \
	done

clean:
	rm -f $(TARGETS) *.o
