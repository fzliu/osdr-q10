#ifndef __CVECTOR_H__
#define __CVECTOR_H__

#include <stddef.h>

#define M_2PI (2 * M_PI)

#define FLOAT_T 1
#define CFLOAT_T 2
#define CFLOAT_SZ 4

// generic vector definition
typedef struct Vector {
    void* data;
    size_t sz;
    size_t len;
    size_t max;
} Vector;

// Vector malloc
Vector* vector_alloc(size_t, size_t);

// Vector read
void* vector_get(Vector*, size_t);

// Vector write
void vector_set(Vector*, size_t, void*);

// Vector length
size_t vector_len(Vector*);

// Vector copy
void vector_copy(Vector*, Vector*, size_t);

// Vector append
void vector_append(Vector*, void*);

// Vector remove
void* vector_remove(Vector*);

// Vector free
void vector_free(Vector*);

#endif
