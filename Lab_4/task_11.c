#include <stdio.h>

int main(void) {
    int n;
    int vote;
    int yes = 0;
    int no = 0;

    if (scanf("%d", &n) != 1 || n <= 0) {
        return 1;
    }

    for (int i = 0; i < n; i++) {
        if (scanf("%d", &vote) != 1) {
            return 1;
        }
        if (vote == 1) {
            yes++;
        } else {
            no++;
        }
    }

    if (yes > no) {
        printf("1\n");
    } else if (no > yes) {
        printf("0\n");
    } else {
        printf("-1\n");
    }

    return 0;
}
