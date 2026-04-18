/* https://schaumont.dyn.wpi.edu/ece4703b20/lecture4.html */
/* https://schaumont.dyn.wpi.edu/ece4703b20/lecture5.html */

#define DEBUG_TEST

#ifdef DEBUG_TEST
/*
#warning "Please undefine DEBUG_TEST."
#define float32_t float
*/
#pragma message("Please undefine DEBUG_TEST.")
#include <stdint.h>
typedef float float32_t;
#endif

#ifndef FILTER_H
#define FILTER_H

#define OUTPUT_GAIN 0.125f

/*
// FIR
typedef struct cascadestate {
	float32_t s[2];  // filter state
	float32_t c[2];  // filter coefficients
} cascadestate_t;

// IIR
typedef struct cascadestate {
	float32_t s[2];   // state
	float32_t b[3];  // nominator coeff  b0 b1 b2
	float32_t a[2];  // denominator coeff   a1 a2
} cascadestate_t;
*/

typedef struct cascadestatefir {
	float32_t s[2];  // filter state
	float32_t c[2];  // filter coefficients
} cascadestatefir_t;

typedef struct cascadestateiir {
	float32_t s[2];   // state
	float32_t b[3];  // nominator coeff  b0 b1 b2
	float32_t a[2];  // denominator coeff   a1 a2
} cascadestateiir_t;

/*
float32_t cascadefir(float32_t x, cascadestate_t *p); // FIR
float32_t cascadeiir(float32_t x, cascadestate_t *p); // IIR
*/

float32_t cascadefir(float32_t x, cascadestatefir_t *p);
float32_t cascadeiir(float32_t x, cascadestateiir_t *p);

/*
void createcascade(float32_t c0, float32_t c1, cascadestate_t *p); // FIR
void createcascade(float32_t b0, float32_t b1, float32_t b2, float32_t a1, float32_t a2, cascadestate_t *p); // IIR
*/

void createcascadefir(float32_t c0, float32_t c1, cascadestatefir_t *p);
void createcascadeiir(float32_t b0, float32_t b1, float32_t b2, float32_t a1, float32_t a2, cascadestateiir_t *p);

/*
void initcascade(); // FIR
void initcascade(); // IIR
*/

void initcascadefir();
void initcascadeiir();

/*
uint16_t processCascade(uint16_t x); // FIR
uint16_t processCascade(uint16_t x); // IIR
*/

float32_t processCascadefir(float32_t x);
float32_t processCascadeiir(float32_t x);

#endif

