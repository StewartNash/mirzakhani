
/* https://schaumont.dyn.wpi.edu/ece4703b20/lecture5.html */

typedef struct cascadestate {
	float32_t b[3]; // Numerator coefficients b0 b1 b2
	float32_t a[2];  // Denominator coefficients a1 a2
} cascadestate_t;
 
float32_t cascadeiir(float32_t x, cascadestate_t *p) {
	float32_t v = x - (p->s[0] * p->a[0]) - (p->s[1] * p->a[1]);
	float32_t y = (v * p->b[0]) + (p->s[0] * p->b[1]) + (p->s[1] * p->b[2]);
	p->s[1] = p->s[0];
	p->s[0] = v;
  
	return y;
}

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

cascadestate_t stage1;
cascadestate_t stage2;
 
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

uint16_t processCascade(uint16_t x) {
	float32_t input = adc14_to_f32(0x1800 + rand() % 0x1000);
	float32_t v;

	v = cascadeiir(input, &stage1);
	v = cascadeiir(v, &stage2);

	return f32_to_dac14(v * 0.125);
}

