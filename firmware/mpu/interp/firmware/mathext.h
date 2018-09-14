#ifndef __MATHEXT_H__
#define __MATHEXT_H__

#include <stddef.h>

#include "vector.h"

// 1-dimensional matrix (mathematical vector)
typedef struct Mat1D {
    Vector* vec;
    int type;
} Mat1D;

// 2-dimensional matrix
/*
typedef struct Mat2D {
    Vector* vec;
    size_t nr;
    int type;
} Mat2D;
*/

// sinc function
float sinc(float);

// Mat1D init
Mat1D* mat1d_init(size_t);

// Mat1D get
float mat1d_get(Mat1D* mat, size_t);

// Mat1D set
void mat1d_set(Mat1D*, size_t, float);

// Mat1D size
size_t mat1d_len(Mat1D*);

// Mat1D copy
void mat1d_copy(Mat1D*, Mat1D*, size_t);

// Mat1D free
void mat1d_free(Mat1D*);

// complex absolute value
Mat1D* mat1d_abs(Mat1D* real, Mat1D* imag);

// convolution operator
Mat1D* mat1d_convolve(Mat1D*, Mat1D*);

#endif
