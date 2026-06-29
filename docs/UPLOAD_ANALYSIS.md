# Upload analysis for EP001 XIAO ESP32C3

## Current status

EP001 v0.7 can be selected in the KidsBlock device list and opens the block editor.
Compilation succeeds with a simple sketch.

Upload fails with:

```text
A fatal error occurred: This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```

## Interpretation

The generated Arduino code is valid enough to compile. The remaining problem is the upload target configuration.
KidsBlock is still using the standard ESP32 upload profile, so the upload tool is invoked as an ESP32 target instead of ESP32-C3.

## Next step

Analyzer v6 searches for:

- Arduino ESP32 `boards.txt`
- `platform.txt`
- XIAO ESP32C3 board definitions
- KidsBlock internal FQBN strings
- tool locations such as `arduino-cli.exe` and `esptool.exe`

The v6 report will decide whether EP001 v0.8 should patch:

1. only the external device definition,
2. Arduino board/FQBN settings,
3. or the KidsBlock app upload profile.
