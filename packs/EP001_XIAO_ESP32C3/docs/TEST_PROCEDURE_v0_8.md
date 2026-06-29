# EP001 v0.8 Test Procedure

## Purpose

Test whether XIAO ESP32C3 upload succeeds after applying a temporary boards.txt alias.

## Important

This version temporarily overrides the generic ESP32 board definition in KidsBlock's bundled ESP32 core.
Use only on the test PC.

## Procedure

1. Close KidsBlock completely.
2. Run:

```text
packs\EP001_XIAO_ESP32C3\installer\install_ep001_xiao_esp32c3_v0_8.bat
```

3. Start KidsBlock.
4. Select `Seeed Studio XIAO ESP32C3`.
5. Use the same simple blink program that compiled successfully in v0.7.
6. Compile.
7. Upload.
8. Record whether upload succeeds.

## After the test

To restore normal ESP32 board behavior, run:

```text
packs\EP001_XIAO_ESP32C3\installer\restore_ep001_xiao_esp32c3_v0_8.bat
```

## Expected result

The upload should no longer show:

```text
This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```
