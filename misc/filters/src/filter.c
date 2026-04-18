#include <math.h>
//#include <stdlib.h>

#include "filter.h"

/*
// FIR
float32_t cascadefir(float32_t x, cascadestate_t *p) {
	float32_t r = x + (p->s[0] * p->c[0]) +  (p->s[1] * p->c[1]);
	p->s[1] = p->s[0];
	p->s[0] = x;
	return r;
}

// IIR
float32_t cascadeiir(float32_t x, cascadestate_t *p) {
	float32_t v = x - (p->s[0] * p->a[0]) - (p->s[1] * p->a[1]);
	float32_t y = (v * p->b[0]) + (p->s[0] * p->b[1]) + (p->s[1] * p->b[2]);
	p->s[1] = p->s[0];
	p->s[0] = v;
  
	return y;
}
*/

float32_t cascadefir(float32_t x, cascadestatefir_t *p) {
	float32_t r = x + (p->s[0] * p->c[0]) +  (p->s[1] * p->c[1]);
	p->s[1] = p->s[0];
	p->s[0] = x;
	return r;
}

float32_t cascadeiir(float32_t x, cascadestateiir_t *p) {
	float32_t v = x - (p->s[0] * p->a[0]) - (p->s[1] * p->a[1]);
	float32_t y = (v * p->b[0]) + (p->s[0] * p->b[1]) + (p->s[1] * p->b[2]);
	p->s[1] = p->s[0];
	p->s[0] = v;
  
	return y;
}

/*
// FIR
void createcascade(float32_t c0,
				   float32_t c1,
				   cascadestate_t *p) {
	p->c[0] = c0;
	p->c[1] = c1;
	p->s[0] = p->s[1] = 0.0f;
}

// IIR
void createcascade(
	float32_t b0,
	float32_t b1,
	float32_t b2,
	float32_t a1,
	float32_t a2,
	cascadestate_t *p) {
	p->b[0] = b0;
	p->b[1] = b1;
	p->b[2] = b2;
	p->a[0] = a1;
	p->a[1] = a2;
	p->s[0] = p->s[1] = 0.0f;
}
*/

void createcascadefir(float32_t c0,
	float32_t c1,
	cascadestatefir_t *p) {
	p->c[0] = c0;
	p->c[1] = c1;
	p->s[0] = p->s[1] = 0.0f;
}

void createcascadeiir(
	float32_t b0,
	float32_t b1,
	float32_t b2,
	float32_t a1,
	float32_t a2,
	cascadestateiir_t *p) {
	p->b[0] = b0;
	p->b[1] = b1;
	p->b[2] = b2;
	p->a[0] = a1;
	p->a[1] = a2;
	p->s[0] = p->s[1] = 0.0f;
}

/*
// FIR
cascadestate_t stage1;
cascadestate_t stage2;
cascadestate_t stage3;
cascadestate_t stage4;

// IIR
cascadestate_t stage1;
cascadestate_t stage2;
*/
 
cascadestatefir_t firstage1;
cascadestatefir_t firstage2;
cascadestatefir_t firstage3;
cascadestatefir_t firstage4;

cascadestateiir_t iirstage1;
cascadestateiir_t iirstage2;

/*
// FIR
void initcascade() {
	createcascade(	  0.0f,  1.0f, &stage1);
	createcascade( M_SQRT2,  1.0f, &stage2);
	createcascade(-M_SQRT2,  1.0f, &stage3);
	createcascade(	  1.0f,  0.0f, &stage4);
}

// IIR
void initcascade() {
	createcascade(1.0f, // b0
		0.0f, // b1
		1.0f, // b2
		-0.7071f, // a1
		0.25f, // a2
		&stage1);
	createcascade(1.0f, // b0
		1.0f, // b1
		0.0f, // b2
		+0.7071f, // a1
		0.25f, // a2
		&stage2);
}
*/

void initcascadefir() {
	createcascadefir(0.0f, 1.0f, &firstage1);
	createcascadefir(M_SQRT2, 1.0f, &firstage2);
	createcascadefir(-M_SQRT2, 1.0f, &firstage3);
	createcascadefir(1.0f, 0.0f, &firstage4);
}

void initcascadeiir() {
	createcascadeiir(1.0f, // b0
		0.0f, // b1
		1.0f, // b2
		-0.7071f, // a1
		0.25f, // a2
		&iirstage1);
	createcascadeiir(1.0f, // b0
		1.0f, // b1
		0.0f, // b2
		+0.7071f, // a1
		0.25f, // a2
		&iirstage2);
}

/*
// FIR
uint16_t processCascade(uint16_t x) {

	float32_t input = adc14_to_f32(0x1800 + rand() % 0x1000);
	float32_t v;
	static float32_t d;

	v = cascadefir(d, &stage1);
	v = cascadefir(v, &stage2);
	v = cascadefir(v, &stage3);
	v = cascadefir(v, &stage4);
	d = input;

	return f32_to_dac14(v * 0.125);
}

// IIR
uint16_t processCascade(uint16_t x) {
	float32_t input = adc14_to_f32(0x1800 + rand() % 0x1000);
	float32_t v;

	v = cascadeiir(input, &stage1);
	v = cascadeiir(v, &stage2);

	return f32_to_dac14(v * 0.125);
}
*/

float32_t processCascadefir(float32_t x) {

	float32_t input = x;
	float32_t v;
	static float32_t d;

	v = cascadefir(d, &firstage1);
	v = cascadefir(v, &firstage2);
	v = cascadefir(v, &firstage3);
	v = cascadefir(v, &firstage4);
	d = input;

	v = v * OUTPUT_GAIN;

	return v;
}

float32_t processCascadeiir(float32_t x) {
	float32_t input = x;
	float32_t v;

	v = cascadeiir(input, &iirstage1);
	v = cascadeiir(v, &iirstage2);
	
	v = v * OUTPUT_GAIN;

	return v;
}

