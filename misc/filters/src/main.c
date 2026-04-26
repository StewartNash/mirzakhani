#include <stdio.h>
#include <math.h>
//#define PI 3.14159265359
#include <stdlib.h>
#include <time.h>

#include "main.h"
#include "filter.h"

int main(int argc, char *argv[]) {
	FILE* file;
	FILE* output;
	int i;
	double amplitude, frequency, time_, phase;
	double x, y;
	
	srand(time(NULL));
	
	file = fopen("data.txt", "w");
	output = fopen("output.txt", "w");
	if (file == NULL) {
		printf("ERROR: Could not create data.txt\r\n");
		return 1;
	}
	
	initcascadefir();

	printf("#START\r\n");
	printf("#RATE=%d\r\n", SAMPLE_RATE_HZ);
	printf("#PERIOD_US=%d\r\n", SAMPLE_PERIOD_US);
	printf("#CHANNEL=%s\r\n", CHANNEL_NAME);
	printf("#UNIT=%s\r\n", UNIT_NAME);
	printf("#COMMENT=%s\r\n", COMMENT_STR);

	fprintf(file, "#START\r\n");
	fprintf(file, "#RATE=%d\r\n", SAMPLE_RATE_HZ);
	fprintf(file, "#PERIOD_US=%d\r\n", SAMPLE_PERIOD_US);
	fprintf(file, "#CHANNEL=%s\r\n", CHANNEL_NAME);
	fprintf(file, "#UNIT=%s\r\n", UNIT_NAME);
	fprintf(file, "#COMMENT=%s\r\n", COMMENT_STR);
	
	fprintf(output, "#START\r\n");
	fprintf(output, "#RATE=%d\r\n", SAMPLE_RATE_HZ);
	fprintf(output, "#PERIOD_US=%d\r\n", SAMPLE_PERIOD_US);
	fprintf(output, "#CHANNEL=%s\r\n", CHANNEL_NAME);
	fprintf(output, "#UNIT=%s\r\n", UNIT_NAME);
	fprintf(output, "#COMMENT=%s\r\n", COMMENT_STR);
	
	amplitude = 1.0;
	frequency = 5.0;
	phase = 0;
        for (i = 0; i < TOTAL_SAMPLES; i++) {
            time_ = i * SAMPLE_PERIOD_US * 1e-6;  // convert to seconds
            x = sine_wave(amplitude, frequency, time_, phase);
            
            if (IS_NOISE_ENABLED) {
                double noise = ((double)rand() / RAND_MAX) * 2.0 - 1.0;
                x += NOISE_AMPLITUDE * noise;
            }
            y = processCascadefir((float)x);       

            printf("%f", x);
            fprintf(file, "%f", x);
            fprintf(output, "%f", y);

            if ((i + 1) % BATCH_SIZE == 0) {
                printf("\r\n");
                fprintf(file, "\r\n");
                fprintf(output, "\r\n");
            } else {
                printf(",");
                fprintf(file, ",");
                fprintf(output, ",");
            }
        }
        
 	printf("#STOP\r\n");
 	fprintf(file, "#STOP\r\n");
 	fprintf(output, "#STOP\r\n");
	
	fclose(file);
	fclose(output);
	printf("Done!\r\n");

	return 0;
}

double sine_wave(double amplitude, double frequency, double time_, double phase) {
	double angularFrequency = 2.0 * M_PI * frequency;
	
	return amplitude * sin(angularFrequency * time_ + phase);
}

