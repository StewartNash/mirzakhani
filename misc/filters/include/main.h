#pragma once

#include <math.h>
//#define PI 3.14159265359

#define BASE_CLOCK 1000000
#define SAMPLE_RATE_HZ 250
#define SAMPLE_PERIOD_US (BASE_CLOCK / SAMPLE_RATE_HZ)

#define CHANNEL_NAME "AUX0"
#define UNIT_NAME "Volts"
#define COMMENT_STR "SysMon AUX0 Sampling"

#define TOTAL_SAMPLES 1000
#define BATCH_SIZE 10 // Print width

double sine_wave(double amplitude, double frequency, double time, double phase) {
	double angularFrequency = 2.0 * M_PI * frequency;
	
	return amplitude * sin(angularFrequency * time + phase);
}

