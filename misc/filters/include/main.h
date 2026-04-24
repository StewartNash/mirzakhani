#pragma once

#include <stdbool.h>

#define BASE_CLOCK 1000000
#define SAMPLE_RATE_HZ 250
#define SAMPLE_PERIOD_US (BASE_CLOCK / SAMPLE_RATE_HZ)

#define CHANNEL_NAME "AUX0"
#define UNIT_NAME "Volts"
#define COMMENT_STR "SysMon AUX0 Sampling"

#define TOTAL_SAMPLES 500
#define BATCH_SIZE 10 // Print width

const bool IS_NOISE_ENABLED = 1;
const double NOISE_AMPLITUDE = 0.1;

double sine_wave(double amplitude, double frequency, double time_, double phase);

