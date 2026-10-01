#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    unsigned long a, b, c, result;

    if (argc != 4) {
        return 1;
    }

    a = strtoul(argv[1], NULL, 10);
    b = strtoul(argv[2], NULL, 10);
    c = strtoul(argv[3], NULL, 10);

    result = ((((b + c) + c) + a) + a);

    printf("%lu\n", result);

    return 0;
}
