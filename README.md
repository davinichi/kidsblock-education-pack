# KidsBlock SDK v0.4

This version adds an experimental upload patch for EP001 Seeed Studio XIAO ESP32C3.

## Main change

KidsBlock 2.0.5 uses the built-in `arduinoEsp32` VM device extension for ESP32 boards. That extension currently uses this FQBN:

```text
esp32:esp32:esp32
```

For XIAO ESP32C3, this causes upload to fail with:

```text
This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```

EP001 v0.8 therefore adds a temporary boards.txt alias so that KidsBlock's existing `esp32:esp32:esp32` upload route behaves like `XIAO_ESP32C3`.

This is a controlled test patch, not the final architecture.

## Test target

- Device list display: already confirmed OK in v0.7
- Block editor: already confirmed OK in v0.7
- Compile: already confirmed OK in v0.7
- Upload: test in v0.8
