#include <stdio.h>
#include <math.h>
#include <time.h>

#include "interp.h"
#include "mathext.h"
#include "vector.h"

#define DEBUG      0
#define DATA_LEN   32

Mat1D* generate_sin_data(void) {

	float tmp;
	Mat1D* sinData = mat1d_init(DATA_LEN);

	for (uint16_t i = 0; i < DATA_LEN; i++) {
		tmp = sin(i * 3.14 / DATA_LEN);
		//mat1d_set(sinData, i, tmp);
		mat1d_set(sinData, i, i);
	}
	
	return sinData;
}

#define a_len   3
#define b_len   4

int mainx(void) {
	Mat1D* a = mat1d_init(a_len);
	for (uint16_t i = 0; i < a_len; i++) {
		mat1d_set(a, i, i + 1);
	}

	Mat1D* b = mat1d_init(b_len);
	for (uint16_t i = 0; i < b_len; i++) {
		mat1d_set(b, i, i + 1);
	}

	printf("b \r\n");
    for (size_t i = 0; i < mat1d_len(b); i++) {
        printf("%f   ", mat1d_get(b, i));
    }
    printf("\r\n");

	Mat1D* Conv = mat1d_convolve(a, b);

    printf("\r\nresult: \r\n");
	for (uint16_t i = 0; i < mat1d_len(Conv); i++) {
		printf("%f   ", mat1d_get(Conv, i));
	}    
	printf("\r\n");

}



void show_time(void) {
	time_t timep;

	time(&timep);
	struct tm *p=gmtime(&timep);
	printf("%d:%d:%d \r\n", p->tm_hour, p->tm_min, p->tm_sec);	
}

int main(void) {

	size_t factor = 20;
	size_t nTaps = 21;

	Mat1D* real = generate_sin_data();

#if DEBUG
	printf("\r\nsource data \r\n");
	for (uint16_t i = 0; i < mat1d_len(real); i++) {
		printf("%f   ", mat1d_get(real, i));
	}
#endif

	Mat1D* realPad = zero_pad(real, factor);
	Mat1D* kern = lpf_sinc(nTaps, factor);	

	show_time();
	for (uint16_t j = 0; j < 800; j++) {
	    Mat1D* realConv = mat1d_convolve(realPad, kern);

	#if DEBUG
	    printf("\r\nresult: \r\n");
		for (uint16_t i = mat1d_len(kern) / 2; i < mat1d_len(realConv); i++) {
			printf("%f   ", mat1d_get(realConv, i));
		}    
		printf("\r\n");
	#endif
		mat1d_free(realConv);
	}
	show_time();
}