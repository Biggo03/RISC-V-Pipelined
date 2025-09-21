int main() {
    int sum = 0;
    for (int i = 1; i <= 10; i++) {
        sum += i;
    }

    volatile int *out = (int*)200; // memory-mapped location
    *out = sum;                    // store result (should be 55)

    while (1);                     // infinite loop
    return 0;
}
