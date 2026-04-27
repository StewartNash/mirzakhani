#define DEBUG_TEST

#ifdef DEBUG_TEST
#pragma message("Please undefine DEBUG_TEST.")
#endif

#ifndef ADC_H
#define ADC_H

#include <stdint.h>
#include <stdlib.h>

#define UUID_SIZE 16

void uuid(char *output);

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

#endif
