/**
 * Author: Frank Liu
 * Company: Orion Innovations
 * Description: Interpolates (upsample + low-pass) complex vectors.
 */

#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "interp.h"
#include "mathext.h"

/**
 * Zero pads the input vector.
 */
Mat1D* zero_pad(Mat1D* mat, uint8_t factor)
{
    size_t matSz = mat1d_len(mat);
    Mat1D* matPad = mat1d_init(matSz * factor);
    for (size_t i = 0; i < matSz; i++) {
        float val = mat1d_get(mat, i);
        mat1d_set(matPad, i * factor, val);
    }
    return matPad;
}

/**
 * Generates windowed sinc lowpass FIR coefficients.
 */
Mat1D* lpf_sinc(size_t nTaps, size_t factor)
{
    float w_c = 1.0 / factor;
    Mat1D* coef = mat1d_init(nTaps);
    for (size_t i = 0; i < nTaps; i++) {
        //float x = (float) i - (float) (nTaps - 1) / 2.0;
        //mat1d_set(coef, i, w_c * sinc(M_PI * w_c * x));
        mat1d_set(coef, i, i);
    }
    return coef;
}

/**
 * Interpolates the input vector by the specified factor.
 */
Mat1D* interp(Mat1D* real, Mat1D* imag, uint8_t nTaps, uint8_t factor)
{
    Mat1D* realPad = zero_pad(real, factor);
    Mat1D* imagPad = zero_pad(imag, factor);
    Mat1D* kern = lpf_sinc(nTaps, factor);
    Mat1D* realConv = mat1d_convolve(realPad, kern);
    Mat1D* imagConv = mat1d_convolve(imagPad, kern);
    return mat1d_abs(realConv, imagConv);
}
