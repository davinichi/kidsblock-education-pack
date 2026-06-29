# Upload Analysis v1.0 RC3

The supplied `2.bundle.js` contains three relevant occurrences:

- generic ESP32 device definition
- ESP32S3 FQBN prefix inside a template string
- duplicate generic ESP32 device definition

RC2 targeted only an exact block. RC3 replaces all exact `esp32:esp32:esp32` strings in all bundle JavaScript files inside `app.asar`.

This is still a validation patch and may temporarily affect normal ESP32 upload.
