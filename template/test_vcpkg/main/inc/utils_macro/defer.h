#ifndef _DEFER_H_
#define _DEFER_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <assert.h>

#define DEFER_MAX 32
#define defer_init            \
    void *_dstack[DEFER_MAX]; \
    void *_ddone;             \
    int _didx = 0
#define ___defer_label(x) _defer_label_##x
#define __defer_label(x) ___defer_label(x)
#define _defer_label __defer_label(__LINE__)
#define defer(code)                    \
    assert(_didx < DEFER_MAX);         \
    _dstack[_didx++] = &&_defer_label; \
    if (0) {                           \
    _defer_label:                      \
        code;                          \
        if (_didx > 0) {               \
            goto *_dstack[--_didx];    \
        } else {                       \
            goto *_ddone;              \
        }                              \
    }
#define defer_done              \
    _ddone = &&_defer_label;    \
    if (_didx > 0) {            \
        goto *_dstack[--_didx]; \
    }                           \
    _defer_label:

#ifdef __cplusplus
}
#endif

#endif

/* EXAMPLE
int test_defer(void) {
    FILE *f;
    char *p;

    defer_init;

    printf("open file demo.txt\n");
    f = fopen("demo.txt", "r");
    if (!f) return 1;
    defer({
        printf("close file demo.txt\n");
        fclose(f);
    });

    printf("malloc memory\n");
    p = malloc(1024);
    if (!p) {
        defer_done;
        return 1;
    }
    defer({
        printf("free memory\n");
        free(p);
    });

    printf("test defer success!!!\n");

    defer_done;

    printf("return from defer\n====================\n");
    return 0;
}
*/
