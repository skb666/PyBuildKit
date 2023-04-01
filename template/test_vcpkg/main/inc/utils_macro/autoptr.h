#ifndef _AUTOPTR_H_
#define _AUTOPTR_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdlib.h>

struct __autoptr {
    size_t cnt;
    char data[0];
};

#define __autoptr_offset__(_type, _name) \
    (size_t)(((_type *)0)->_name)
#define __autoptr_container__(_type, _name, _ptr) \
    ((_type *)((char *)(_ptr)-__autoptr_offset__(_type, _name)))

__attribute__((always_inline)) static inline void autoptr_cleanup(void *_ptr) {
    void *ptr = (void *)*(void **)_ptr;
    if (ptr == NULL)
        return;
    struct __autoptr *container =
        __autoptr_container__(struct __autoptr, data, ptr);
    if (--container->cnt == 0)
        free(container);
}

#define autoptr_def(_type, _name) \
    _type _name __attribute__((cleanup(autoptr_cleanup))) = NULL

#define autoptr_new(_name, _size)                                                 \
    do {                                                                          \
        struct __autoptr *container = NULL;                                       \
        if (_name != NULL) {                                                      \
            container = __autoptr_container__(struct __autoptr, data, ptr);       \
            free(container);                                                      \
        }                                                                         \
        container = (struct __autoptr *)malloc(sizeof(struct __autoptr) + _size); \
        container->cnt = 1;                                                       \
        _name = (__typeof__(_name))container->data;                               \
    } while (0)

#define autoptr_cpy(_name) \
    (_name != NULL && __autoptr_container__(struct __autoptr, data, _name)->cnt++) ? _name : NULL

#ifdef __cplusplus
}
#endif

#endif /* _AUTOPTR_H_ */


/* EXAMPLE
void *test(void) {
    printf("start test\n");
    autoptr_def(void *, ptr);
    autoptr_new(ptr, sizeof(int) * 20);
    autoptr_new(ptr, sizeof(int) * 200);
    printf("end test\n");
    return autoptr_cpy(ptr);
}

void test_autoptr(void) {
    printf("into main\n");
    autoptr_def(void *, ptr);
    ptr = test();
    printf("check\n");
    printf("return from autoptr\n====================\n");
}
*/
