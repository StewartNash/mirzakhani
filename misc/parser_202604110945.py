import numpy as np
import matplotlib.pyplot as plt

FILE_NAME = "data.txt"

def parse_sessions(filename):
    sessions = []
    metadata = {}
    current_data = []
    recording = False

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()

            # --- START ---
            if line == "#START":
                recording = True
                metadata = {}
                current_data = []
                continue

            # --- STOP ---
            if line == "#STOP":
                if current_data:
                    sessions.append({
                        "metadata": metadata,
                        "data": np.array(current_data)
                    })
                recording = False
                continue

            if not recording:
                continue

            # --- Metadata ---
            if line.startswith("#"):
                try:
                    key, value = line[1:].split("=", 1)
                    metadata[key] = value
                except ValueError:
                    continue
                continue

            # --- Data ---
            try:
                values = [float(x) for x in line.split(",") if x]
                current_data.extend(values)
            except ValueError:
                continue

    return sessions


# ===== Load =====
sessions = parse_sessions(FILE_NAME)

if not sessions:
    print("No valid sessions found.")
    exit()

# ===== Use latest session =====
session = sessions[-1]
data = session["data"]
meta = session["metadata"]

# ===== Extract metadata safely =====
rate = int(meta.get("RATE", 0))
period_us = int(meta.get("PERIOD_US", 0))
channel = meta.get("CHANNEL", "Unknown")
unit = meta.get("UNIT", "")
comment = meta.get("COMMENT", "")

# ===== Time axis =====
if rate > 0:
    t = np.arange(len(data)) / rate
else:
    t = np.arange(len(data))

# ===== Plot =====
plt.figure()
plt.plot(t, data)

plt.title(f"{channel} ({unit}) | {rate} Hz\n{comment}")
plt.xlabel("Time (s)" if rate > 0 else "Sample Index")
plt.ylabel(unit)
plt.grid(True)

plt.show()

