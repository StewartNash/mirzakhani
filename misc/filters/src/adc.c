#include <stdint.h>
#include <stdlib.h>

#include "adc.h"

// v4 UUID generator
void uuid(char *output) {
	uint8_t bytes[UUID_SIZE];

	for (int i = 0; i < UUID_SIZE; i++) {
		bytes[i] = rand() & 0xFF;
	}
	// Set version (4) - bits 12-15 of time_hi_and_version
	bytes[6] = (bytes[6] & 0x0F) | 0x40;
	// Set variant (FC4122) - bits 6-7 of clock_seq_hi_and_reserved
	bytes[8] = (bytes[8] & 0x3F) | 0x80;
}

void print_uuid(char *message, char *bytes) {
	sprintf(message,
		"%02x%02x%02x%02x-"
		"%02x%02x-"
		"%02x%02x-"
		"%02x%02x-"
		"%02x%02x%02x%02x%02x%02x",
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12],
		bytes[13], bytes[14], bytes[15]
	);
}

void fprint_uuid(FILE *file, char *bytes) {
	fprintf(file,
		"%02x%02x%02x%02x-"
		"%02x%02x-"
		"%02x%02x-"
		"%02x%02x-"
		"%02x%02x%02x%02x%02x%02x",
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12],
		bytes[13], bytes[14], bytes[15]
	);
}

void printheader(struct session my_session) {
	/*
	printf("#START\r\n");
	printf("#RATE=%d\r\n", (int)my_session.sample_rate_hz);
	printf("#PERIOD_US=%d\r\n", (int)my_session.sample_period_us);
	printf("#CHANNEL=%s\r\n", my_session.channel_name);
	printf("#UNIT=%s\r\n", my_session.unit_name);
	printf("#COMMENT=%s\r\n", my_session.comment_str);
	*/
	
	printf("#START\r\n");
	printf("#RATE=%f\r\n", my_session.sample_rate_hz);
	printf("#PERIOD_US=%f\r\n", my_session.sample_period_us);
	printf("#CHANNEL=%s\r\n", my_session.channel_name);
	printf("#UNIT=%s\r\n", my_session.unit_name);
	printf("#COMMENT=%s\r\n", my_session.comment_str);	
}

void fprintheader(FILE* file, struct session my_session) {
	/*
	fprintf(file, "#START\r\n");
	fprintf(file, "#RATE=%d\r\n", (int)my_session.sample_rate_hz);
	fprintf(file, "#PERIOD_US=%d\r\n", (int)my_session.sample_period_us);
	fprintf(file, "#CHANNEL=%s\r\n", my_session.channel_name);
	fprintf(file, "#UNIT=%s\r\n", my_session.unit_name);
	fprintf(file, "#COMMENT=%s\r\n", my_session.comment_str);
	*/
	
	fprintf(file, "#START\r\n");
	fprintf(file, "#RATE=%f\r\n", my_session.sample_rate_hz);
	fprintf(file, "#PERIOD_US=%f\r\n", my_session.sample_period_us);
	fprintf(file, "#CHANNEL=%s\r\n", my_session.channel_name);
	fprintf(file, "#UNIT=%s\r\n", my_session.unit_name);
	fprintf(file, "#COMMENT=%s\r\n", my_session.comment_str);
}

void printfooter() {
 	printf("#STOP\r\n");
}

void fprintfooter(FILE* file) {
 	fprintf(file, "#STOP\r\n");
}

