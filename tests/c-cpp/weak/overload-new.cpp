#include <iostream>
#include <stdlib.h>

static int news = 0, deletes = 0;

void *operator new(size_t size) { news++; return malloc(size); }
void operator delete(void *ptr) noexcept { deletes++; free(ptr); }

int main(int argc, const char *argv[]) {
    std::cout << "";
    delete new int;
    // std::cout << news << " " << deletes << std::endl;

    return news == 0 || deletes == 0;;
}
