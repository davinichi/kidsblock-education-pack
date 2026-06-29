# Development Log

## v0.6

- Added Analyzer v7.
- Upload problem remains: KidsBlock still calls ESP32 upload path for ESP32-C3.
- v0.9 did not fix the upload path.

## v0.7

Added Analyzer v8 to collect upload engine files from `app.asar.unpacked`, especially `openblock-link`. This is needed because the upload error still shows that the runtime is using ESP32 rather than ESP32-C3.
