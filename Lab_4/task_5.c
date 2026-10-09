#include <stdio.h>

int main(void) {
    long n;
    long count = 0;

    if (scanf("%ld", &n) != 1) {
        return 1;
    }

    for (long i = 1; i <= n; i++) {
        if (i % 11 != 0 && i % 5 != 0) {
            count++;
        }
    }

    printf("%ld\n", count);

    return 0;
}
