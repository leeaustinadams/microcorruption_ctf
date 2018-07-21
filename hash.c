// gcc -o hash hash.c

#include <stdio.h>
#include <string.h>

struct table_entry {
    char name[16];
    union {
        __int16_t authorized:1;
        __int16_t pin:15;
    } auth_and_pin;
};

__int16_t hash(const char *value) {
    __int16_t result = 0;
    for (unsigned long i = 0; i < strlen(value); i++) {
        __int16_t c = (__int16_t) value[i];
        result = (result + c) * 31;
    }
    return result;
}

int main(int argc, char *argv[]) {
    char input[1024];
    int hex = 0;
    if (argc < 2) {
        return 0;
    } else if (argc > 2 && (!strcmp(argv[2], "-hex"))) {
        unsigned long i;
        for (i = 0; i < strlen(argv[1]); i++) {
            sprintf(input + i*2, "%2x", *(argv[1] + i));
        }
        input[i*2] = 0;
        hex = 1;
    } else {
        strncpy(input, argv[1], sizeof(input));
    }

    __int16_t digest = hash(input);
    char buf[1024];
    unsigned long i;
    if (hex) {
        strcpy(buf, input);
    } else {
        for (i = 0; i < strlen(input); i++) {
            sprintf(buf + i*3, "%2x ", *(input + i));
        }
        buf[i*3-1] = 0;
    }
    printf("hash %s (%s) = 0x%x lowest 5 bits = 0x%x\n", input, buf, digest, digest & 0x1f);
    for (i = 0; i < 14; ++i) {
        buf[i] = '`';
    }
    buf[5] = 0x80;
    buf[6] = 0x80;
    buf[7] = 0;
    printf("hash = 0x%x lowest 5 bits = 0x%x\n", hash(buf), hash(buf) & 0x1f);
    return 0;
}
