# KidsBlock SDK v0.8

## Purpose

EP001 XIAO ESP32C3 upload test.

This version changes the XIAO ESP32C3 kit FQBN from the generic ESP32 board:

```text
esp32:esp32:esp32
```

to the XIAO ESP32C3 board:

```text
esp32:esp32:XIAO_ESP32C3
```

This should make Arduino CLI use `esp32c3` during upload instead of `esp32`.

## Test target

```text
%APPDATA%\KidsBlock\Data\external-resources\extensions\arduino\kit\XIAOESP32C3\index.js
```

## How to test

1. Close KidsBlock completely.
2. Run:
   `packs\EP001_XIAO_ESP32C3\installer\install_ep001_xiao_esp32c3_v1_0_upload_test.bat`
3. Start KidsBlock.
4. Select Seeed Studio XIAO ESP32C3.
5. Compile and upload a simple blink program.
6. If needed, run:
   `packs\EP001_XIAO_ESP32C3\installer\restore_ep001_xiao_esp32c3_v1_0_upload_test.bat`
