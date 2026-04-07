#include <math.h>

// ===== Configuration =====
#define DAC_PIN 25
#define TABLE_SIZE 256
#define SCALING 3.0

uint8_t cosineTable[TABLE_SIZE];

volatile float frequency = 100.0;
volatile int sampleRate = 256;
volatile float amplitude = 2.0;
volatile bool noiseEnable = true;
volatile float noiseLevel = 0.075;

// ===== Timer =====
hw_timer_t *timer = NULL;
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

volatile int sampleIndex = 0;

// ===== Noise =====
inline float generateNoise() {
  if (!noiseEnable) return 0;
  int n = random(-128, 128);
  return noiseLevel * n;
}

// ===== ISR =====
void IRAM_ATTR onTimer() {
  portENTER_CRITICAL_ISR(&timerMux);

  dacWrite(DAC_PIN, cosineTable[sampleIndex]);

  sampleIndex++;
  if (sampleIndex >= TABLE_SIZE) {
    sampleIndex = 0;
  }

  portEXIT_CRITICAL_ISR(&timerMux);
}

// ===== Table =====
void buildTable() {
  for (int i = 0; i < TABLE_SIZE; i++) {
    float angle = 2.0 * PI * i / TABLE_SIZE;
    float value = cos(angle);
    value = value * amplitude / SCALING;

    cosineTable[i] = (uint8_t)(127.5 + 127.5 * value + generateNoise());
  }
}

// ===== Update Frequency =====
void updateFrequency(float freq) {
  frequency = freq;
  sampleRate = TABLE_SIZE * frequency;

  uint64_t alarm_value = 1000000 / sampleRate; // timer ticks (1 MHz base)

  timerAlarm(timer, alarm_value, true, 0);
}

// ===== Setup =====
void setup() {
  buildTable();

  // NEW API: timer frequency in Hz (1 MHz here)
  timer = timerBegin(1000000);  

  timerAttachInterrupt(timer, &onTimer);

  updateFrequency(frequency);
}

// ===== Loop =====
void loop() {
}

