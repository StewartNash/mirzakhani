#include <math.h>

// ===== Configuration =====
#define DAC_PIN 25           // DAC1 (GPIO25)
#define TABLE_SIZE 256       // Higher = smoother waveform

// ===== Waveform Table =====
uint8_t cosineTable[TABLE_SIZE];

// ===== Signal Parameters =====
volatile float frequency = 1.0;   // Hz (adjust this)
volatile int sampleRate = 256;    // samples per second (TABLE_SIZE * freq)

// ===== Timer =====
hw_timer_t *timer = NULL;
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

volatile int index = 0;

// ===== Timer ISR =====
void IRAM_ATTR onTimer() {
  portENTER_CRITICAL_ISR(&timerMux);

  dacWrite(DAC_PIN, cosineTable[index]);

  index++;
  if (index >= TABLE_SIZE) {
    index = 0;
  }

  portEXIT_CRITICAL_ISR(&timerMux);
}

// ===== Build Cosine Table =====
void buildTable() {
  for (int i = 0; i < TABLE_SIZE; i++) {
    float angle = 2.0 * PI * i / TABLE_SIZE;
    float value = cos(angle);  // cosine wave

    // Scale from [-1,1] → [0,255]
    cosineTable[i] = (uint8_t)(127.5 + 127.5 * value);
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
