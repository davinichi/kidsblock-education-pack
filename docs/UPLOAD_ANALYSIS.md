# Upload Analysis

## Confirmed symptom

KidsBlock shows and compiles the XIAO ESP32C3 device, but upload fails with:

```text
A fatal error occurred: This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```

## Cause

The built-in VM device extension `arduinoEsp32` uses:

```text
fqbn: esp32:esp32:esp32
```

Therefore `arduino-cli upload` generates an ESP32 upload command. The actual connected chip is ESP32-C3, so esptool rejects it.

## v0.8 workaround

The test patch modifies the bundled ESP32 `boards.txt` by appending an alias block:

```text
# EP001_XIAO_ESP32C3_ALIAS_BEGIN
esp32.... = values copied from XIAO_ESP32C3....
# EP001_XIAO_ESP32C3_ALIAS_END
```

This makes KidsBlock's fixed FQBN `esp32:esp32:esp32` resolve to XIAO ESP32C3 settings.

## Risk

While this patch is installed, the normal ESP32 board definition in KidsBlock is temporarily overridden. Use only on the test PC. Use the restore script after testing.

## Final direction

The final implementation should avoid overriding the generic ESP32 board. A later version should add a dedicated ESP32-C3 VM device extension or patch the FQBN selection logic more precisely.
