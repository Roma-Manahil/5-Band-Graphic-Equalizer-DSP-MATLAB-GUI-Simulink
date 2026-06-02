# 5-Band Graphic Equalizer (MATLAB + Simulink)

## Overview

This project presents the **design and implementation of a 5-band graphic equalizer** using **MATLAB, Simulink, and Digital Signal Processing (DSP)** concepts.

The system enables **real-time audio processing**, allowing users to dynamically adjust frequency bands and observe both **time-domain and frequency-domain transformations**.

---

## Key Features

* 5-band equalizer (ISO standard frequencies)
* Real-time audio processing
* Interactive MATLAB GUI
* Time & frequency domain visualization
* Playback of original and processed signals
* Automatic normalization to prevent clipping
* DSP-based filter design using Butterworth filters

---

## System Architecture

```
Input Audio → Bandpass Filters → Gain Adjustment → Summation → Output Audio
```

* Audio is split into **5 parallel bands**
* Each band is filtered using **Butterworth bandpass filters**
* Individual gains are applied
* Signals are recombined to produce final output

---

## Frequency Bands

| Band | Frequency | Purpose      |
| ---- | --------- | ------------ |
| 1    | 63 Hz     | Bass         |
| 2    | 250 Hz    | Low Midrange |
| 3    | 1 kHz     | Midrange     |
| 4    | 4 kHz     | Presence     |
| 5    | 16 kHz    | Brilliance   |

---

## Technical Details

* **Sampling Frequency:** 62 kHz
* **Filter Type:** Butterworth Bandpass
* **Order:** 3
* **Q Factor:** Constant (0.6)
* **Gain Range:** -12 dB to +12 dB

---

## GUI Features

* Load audio files (.wav, .mp3, .flac)
* Adjustable sliders for each frequency band
* Real-time signal visualization:

  * Time domain
  * Frequency spectrum
* Play:

  * Original audio
  * Processed audio
* Reset gains instantly

---

## Signal Processing Workflow

1. Audio is loaded and normalized
2. Passed through 5 bandpass filters
3. Each band is scaled by gain
4. All bands are summed
5. Output is normalized and played

---

## Simulink Implementation

* Parallel filter structure
* Real-time signal flow modeling
* Gain blocks for each band
* Summation block for output

---

## Results

* Achieved near-flat response (±1 dB deviation)
* Enhanced:

  * Speech clarity
  * Bass richness
  * Instrument balance
* Stable real-time performance

---

## 📁 Project Structure

```
├── equalizer_gui.m
├── filter_design.m
├── eq_filters.mat
├── simulink_model.slx
├── report.pdf
├── screenshots/
```

---

## How to Run

1. Run filter design script:

```matlab
filter_design
```

2. Launch GUI:

```matlab
equalizer_gui
```

3. Load audio and start experimenting 

---

## Applications

* Music production
* Audio enhancement systems
* Hearing aid preprocessing
* Broadcasting & media
* Embedded DSP systems

---

## Future Improvements

* Dynamic Q-factor control
* Real-time streaming input
* Mobile/embedded implementation
* AI-based adaptive equalization

---

## Author
Computer Engineering Student | DSP & Embedded Systems Enthusiast
