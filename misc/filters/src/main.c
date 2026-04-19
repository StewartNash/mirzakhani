#include <stdio.h>

#include "main.h"
#include "filter.h"

int main(int argc, char *argv[]) {
	FILE* file;
	
	file = fopen("data.txt", "w");
	if (file == NULL) {
		printf("ERROR: Could not create data.txt\r\n");
		return 1;
	}

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
	
	fclose(file);
	printf("Done!\r\n");

	return 0;
}
