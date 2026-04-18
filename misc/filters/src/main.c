#include <stdio.h>

#include "main.h"
#include "filter.h"

int main(int argc, char *argv[]) {
	printf("#START\r\n");
	printf("#RATE=%d\r\n", SAMPLE_RATE_HZ);
	printf("#PERIOD_US=%d\r\n", SAMPLE_PERIOD_US);
	printf("#CHANNEL=%s\r\n", CHANNEL_NAME);
	printf("#UNIT=%s\r\n", UNIT_NAME);
	printf("#COMMENT=%s\r\n", COMMENT_STR);

	printf("Done!\r\n");
}
