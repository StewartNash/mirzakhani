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

void print_uuid(char *bytes) {
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

void printheader(session my_session) {

}

void fprintheader(FILE* file, session my_session) {

}

void printfooter() {
 	printf("#STOP\r\n");
}

void fprintfooter(FILE* file) {
 	fprintf(file, "#STOP\r\n");
}

