# Development Log

## SDK v0.2

- Analyzed `openblock-resource/src/device.js` from `app.asar`.
- Confirmed device files are loaded from nested folder structure.
- Previous installers likely failed because the device was installed too shallow.
- Added Analyzer v5 and EP001 display-only installer v0.7.


## 2026-06-29 EP001 v0.7 test

XIAO ESP32C3 appears in the KidsBlock device list and the block editor opens.
Compilation succeeds, but upload fails because the upload tool still targets ESP32 instead of ESP32-C3.
Analyzer v6 was added to locate board definitions and upload/FQBN settings.
