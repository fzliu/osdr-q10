/**
 * Author: Frank Liu
 * Company: Orion Innovations
 * Description: Orion-specific extension to <cmath> library.
 */

#include <float.h>
#include <stdbool.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>

#include "mathext.h"
#include "vector.h"


/**
 * Computes the sinc operator, i.e. sin(x) / x.
 */
inline float sinc(float x)
{
    if (-FLT_EPSILON < x && x < FLT_EPSILON) {
        return 1.0;
    }
    return sin(x) / x;
}

/**
 * Creates a Mat1D "object" of specified length.
 */
inline Mat1D* mat1d_init(size_t len)
{
    Mat1D* mat = malloc(sizeof(Mat1D));
    mat->vec = vector_alloc(sizeof(float), len);
    //mat->type = type;
    return mat;
}

/**
 * Returns the value at the specified index.
 */
inline float mat1d_get(Mat1D* mat, size_t idx)
{
    float value = * (float *) vector_get(mat->vec, idx);
    return value;
}

/**
 * Writes a value into the specified index.
 */
inline void mat1d_set(Mat1D* mat, size_t idx, float value)
{
    vector_set(mat->vec, idx, &value);
}

/**
 * Returns the length of the input Mat1D.
 */
inline size_t mat1d_len(Mat1D* mat)
{
    return vector_len(mat->vec);
}

/**
 * Copies source to destination with offset.
 */
inline void mat1d_copy(Mat1D* to, Mat1D* from, size_t idx)
{
    vector_copy(to->vec, from->vec, idx);
}

/**
 * Frees memory used to store a Mat1D.
 */
inline void mat1d_free(Mat1D* mat)
{
    vector_free(mat->vec);
}

/**
 * Returns the absolute value of the Mat1D pair.
 * Mat1D pair is interpreted as a complex Mat1D.
 */
Mat1D* mat1d_abs(Mat1D* real, Mat1D* imag)
{
    size_t sz = mat1d_len(real);
    assert(sz == mat1d_len(imag));
    Mat1D* out = mat1d_init(sz);
    for (size_t i = 0; i < sz; i++) {
        float a = mat1d_get(real, i);
        float b = mat1d_get(imag, i);
        mat1d_set(out, i, sqrt(a * a + b * b));
    }
    return out;
}

/**
 * Convolves two input vectors.
 */
Mat1D* mat1d_convolvex(Mat1D* mat, Mat1D* kern)
{
    size_t msz = mat1d_len(mat);
    size_t ksz = mat1d_len(kern);
    Mat1D* mat2 = mat1d_init(msz + 2 * ksz - 2);

    Mat1D* corr = mat1d_init(msz + ksz - 1);
    mat1d_copy(mat2, mat, ksz - 1);

    //float *buf = malloc(msz + ksz - 1);

    // perform convolution
    size_t len = mat1d_len(corr);

    for (size_t i = 0; i < len; i++) {
        for (size_t j = 0; j < ksz; j++) {
            float a = mat1d_get(mat2, i + j);
            float b = mat1d_get(kern, ksz - j - 1);
            float c = mat1d_get(corr, i);

            //buf[i] = c + a * b;
            //mat1d_set(corr, i, c + a * b);
            //test_buf[i] = c + a * b;
            ((float*) corr->vec->data)[i] = c + a * b;
        }
    }

    return corr;
}

Mat1D* mat1d_convolve(Mat1D* mat, Mat1D* kern) {
    float a, b, c;
    size_t msz = mat1d_len(mat);
    size_t ksz = mat1d_len(kern);
    size_t csz = msz + ksz - 1;
    Mat1D* corr = mat1d_init(csz);

    for (size_t i = 0; i < csz; i++) {
        size_t begin = (i < ksz) ? 0 : (i - ksz + 1);
        size_t end = (i < msz) ? (i + 1) : msz;
        c = 0;
        for (size_t j = begin; j < end; j++) {
            a = mat1d_get(mat, j);
            b = mat1d_get(kern, i - j);

            c += a * b;
        }
        mat1d_set(corr, i, c);
    }
    //memcpy(corr->vec->data, buf, corr->vec->len * sizeof(float));
    return corr;
}