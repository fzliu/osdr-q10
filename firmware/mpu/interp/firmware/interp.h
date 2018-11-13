
#ifndef __INTERP_H__
#define __INTERP_H__

#include <stddef.h>
#include <stdint.h>

#include "mathext.h"

// complex interpolation
Mat1D* interp(Mat1D*, Mat1D*, uint8_t, uint8_t);

#endif
