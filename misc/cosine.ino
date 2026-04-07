#include <math.h>

// ===== Configuration =====
#define DAC_PIN 25           // DAC1 (GPIO25)
#define TABLE_SIZE 256       // Higher = smoother waveform

#define SCALING 3.0

// ===== Waveform Table =====
uint8_t cosineTable[TABLE_SIZE];

// ===== Signal Parameters =====
volatile float frequency = 10.0;   // Hz (adjust this)
volatile int sampleRate = 256;    // samples per second (TABLE_SIZE * freq)
volatile float amplitude = 2.0;
volatile bool noiseEnable = true;
volatile float noiseLevel = 0.1;    // 0.0 to 1.0 (relative noise strength)


// ===== Timer =====
hw_timer_t *timer = NULL;
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

volatile int sampleIndex = 0;

// ===== Generate White Noise =====
inline float generateNoise() {
  if (!noiseEnable) return 0;

  // random() → 0 to 255
  int n = random(-128, 128);  // centered noise

  return noiseLevel * n;
}

// ===== Timer ISR =====
void IRAM_ATTR onTimer() {
  portENTER_CRITICAL_ISR(&timerMux);

  dacWrite(DAC_PIN, cosineTable[sampleIndex]);
  
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
    float value = cos(angle);  // cosine wave
    value = value * amplitude / SCALING;

    // Scale from [-1,1] → [0,255]
    cosineTable[i] = (uint8_t)(127.5 + 127.5 * value + generateNoise());
  }
}

// ===== Update Timer Frequency =====
void updateFrequency(float freq) {
  frequency = freq;
  sampleRate = TABLE_SIZE * frequency;

  // Timer runs at 80 MHz / prescaler
  int prescaler = 80; // 1 MHz timer clock
  int timerFreq = 1000000 / sampleRate;

  timerAlarmWrite(timer, timerFreq, true);
}

void setup() {
  buildTable();

  // Setup timer (timer 0, prescaler 80 → 1 MHz tick)
  timer = timerBegin(0, 80, true);

  timerAttachInterrupt(timer, &onTimer, true);

  updateFrequency(1.0); // 1 Hz default

  timerAlarmEnable(timer);
}

void loop() {
  // Example: adjust frequency dynamically here if desired

  // Example placeholder:
  // frequency = 0.5 → 2 Hz etc.
}
