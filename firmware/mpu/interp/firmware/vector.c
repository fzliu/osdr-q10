/**
 * Author: Frank Liu
 * Company: Orion Innovations
 * Description: Multi-type vector implementation.
 */

#include <assert.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "vector.h"

/**
 * Gets the smallest power of two greater than or equal to the input.
 * Useful for power-2 aligning data allocations.
 */
size_t pow2_ceil(size_t n)
{
    assert(n-- > 0);
    for (size_t i = 1; i < sizeof(size_t); i *= 2) {
        n |= n >> i;
    }
    return ++n;
}

/**
 * Allocates a new Vector of specified size.
 */
inline Vector* vector_alloc(size_t sz, size_t len)
{
    Vector* vec = (Vector*) malloc(sizeof(Vector));
    vec->sz = sz;
    vec->len = len;
    vec->max = pow2_ceil(len);
    vec->data = malloc(vec->max * sz);
    memset(vec->data, 0, len * sz);
    return vec;
}

/**
 * Returns the value at the specified index.
 */
inline void* vector_get(Vector* vec, size_t idx)
{
    assert(idx < vec->len);
    return &vec->data[vec->sz*idx];
}

/**
 * Writes a value into the specified index.
 */
inline void vector_set(Vector* vec, size_t idx, void* value)
{
    assert(idx < vec->len);
    memcpy(&vec->data[vec->sz*idx], value, vec->sz);
}

/**
 * Returns the length of the input Vector.
 */
inline size_t vector_len(Vector* vec)
{
    return vec->len;
}

/**
 * Copies source to destination with offset.
 */
void vector_copy(Vector* to, Vector* from, size_t idx)
{
    assert(to->sz == from->sz);
    assert(to->len > from->len + idx);
    memcpy(&to->data[to->sz*idx], from->data, from->sz * from->len);
}

/**
 * Adds a new value to the input Vector.
 */
void vector_append(Vector* vec, void* value)
{
    if (vec->len == vec->max) {
        vec->max *= 2;
        realloc(vec->data, vec->sz * vec->max);
    }
    memcpy(&vec->data[vec->sz*vec->len++], value, vec->sz);
}

/**
 * Removes a value from the end of the Vector.
 */
void* vector_remove(Vector* vec)
{
    vec->len -= 1;
    return &vec->data[vec->len];
}

/**
 * Frees memory used to store a Vector.
 */
void vector_free(Vector* vec)
{
    free(vec->data);
    vec->len = 0;
    vec->sz = 0;
}
