#define DEBUG_TEST

#ifdef DEBUG_TEST
#pragma message("Please undefine DEBUG_TEST.")
#endif

#include <stdio.h>

#ifndef ADC_H
#define ADC_H

#define UUID_SIZE 16

struct session {
	//int sample_rate_hz;
	float sample_rate_hz;
	float sample_period_us;
	char *channel_name;
	char *unit_name;
	char *comment_str;
	
	int total_samples;
	int batch_size;

	int sysmon_device_id;
};

void uuid(char *output);
void print_uuid(char *message, char *bytes);
void fprint_uuid(FILE* file, char *bytes);
void printheader(struct session my_session);
void fprintheader(FILE* file, struct session my_session);
void printfooter();
void fprintfooter(FILE* file);

#endif
