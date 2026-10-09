#include <stdio.h>

int main(void) {
    unsigned long n;

    if (scanf("%lu", &n) != 1) {
        return 1;
    }

    for (unsigned long k = 1; k <= n; k++) {
        unsigned long p = 10;
        while (p <= k) {
            p *= 10;
        }
        if ((k * k) % p == k) {
            printf("%lu\n", k);
        }
    }

    return 0;
}
