#include <math.h>

// ===== Configuration =====
#define DAC_PIN 25
#define TABLE_SIZE 256

// ===== Waveform Table =====
uint8_t cosineTable[TABLE_SIZE];

// ===== Signal Parameters =====
volatile float frequency = 1.0;     // Hz
volatile float amplitude = 1.0;     // 0.0 to 1.0 (scales 2Vpp max)
volatile bool noiseEnable = false;
volatile float noiseLevel = 0.1;    // 0.0 to 1.0 (relative noise strength)

volatile int sampleRate;

// ===== Timer =====
hw_timer_t *timer = NULL;
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

volatile int sampleIndex = 0;

// ===== Generate White Noise =====
inline int generateNoise() {
  if (!noiseEnable) return 0;

  // random() → 0 to 255
  int n = random(-128, 128);  // centered noise

  return (int)(noiseLevel * n);
}

// ===== Timer ISR =====
void IRAM_ATTR onTimer() {
  portENTER_CRITICAL_ISR(&timerMux);

  int base = cosineTable[sampleIndex] - 128;  // center at 0

  // Apply amplitude scaling (max = 127 → ~1V swing)
  int scaled = (int)(amplitude * base);

  // Add noise
  int noisy = scaled + generateNoise();

  // Re-center to DAC range
  int output = noisy + 128;

  // Clamp to 8-bit DAC range
  if (output < 0) output = 0;
  if (output > 255) output = 255;

  dacWrite(DAC_PIN, output);

  sampleIndex++;
  if (sampleIndex >= TABLE_SIZE) {
    sampleIndex = 0;
  }

  portEXIT_CRITICAL_ISR(&timerMux);
}

// ===== Build Cosine Table =====
void buildTable() {
  for (int i = 0; i < TABLE_SIZE; i++) {
    float angle = 2.0 * PI * i / TABLE_SIZE;
    float value = cos(angle);

    cosineTable[i] = (uint8_t)(127.5 + 127.5 * value);
  }
}

// ===== Update Frequency =====
void updateFrequency(float freq) {
  frequency = freq;
  sampleRate = TABLE_SIZE * frequency;

  int timerPeriod_us = 1000000 / sampleRate;
  timerAlarmWrite(timer, timerPeriod_us, true);
}

void setup() {
  Serial.begin(115200);

  buildTable();

  timer = timerBegin(0, 80, true); // 1 MHz timer
  timerAttachInterrupt(timer, &onTimer, true);

  updateFrequency(1.0); // default 1 Hz

  timerAlarmEnable(timer);

  randomSeed(analogRead(34)); // seed noise
}

void loop() {
  // ===== Serial Control =====
  if (Serial.available()) {
    char cmd = Serial.read();

    if (cmd == 'f') {
      float f = Serial.parseFloat();
      if (f > 0.01 && f < 50) updateFrequency(f);
    }

    if (cmd == 'a') {
      float a = Serial.parseFloat();
      if (a >= 0.0 && a <= 1.0) amplitude = a;
    }

    if (cmd == 'n') {
      noiseEnable = !noiseEnable;
    }

    if (cmd == 'l') {
      float nl = Serial.parseFloat();
      if (nl >= 0.0 && nl <= 1.0) noiseLevel = nl;
    }
  }
}

