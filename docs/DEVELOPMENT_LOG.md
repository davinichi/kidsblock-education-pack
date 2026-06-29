# Development Log

## SDK v0.4 / EP001 v0.8

- Added experimental upload workaround for XIAO ESP32C3.
- Confirmed cause: KidsBlock built-in `arduinoEsp32` VM extension uses `esp32:esp32:esp32`.
- Workaround: append a controlled alias block to KidsBlock's bundled ESP32 `boards.txt` so `esp32.*` inherits the `XIAO_ESP32C3.*` board settings.
- Added restore script to revert `boards.txt` to the original backup.

## SDK v0.3 / EP001 v0.7

- Device list display: OK.
- Block editor opens: OK.
- Code generation: OK.
- Compile: OK.
- Upload: failed because upload still used ESP32 instead of ESP32-C3.
