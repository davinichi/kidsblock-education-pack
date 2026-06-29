# Upload Analysis

## Current issue

Upload fails with:

```text
This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```

This means the final upload command still uses ESP32 parameters even though the selected device is XIAO ESP32C3.

## v0.9 result

v0.9 did not resolve the upload path. Compile still succeeds, but upload still uses ESP32.

## Next step

Analyzer v7 collects:

- active device and kit files
- bundled ESP32 `boards.txt`
- bundled ESP32 `platform.txt`
- Arduino15 ESP32 packages
- upload-related JavaScript references
- arduino-cli board list and config

No modification is performed by Analyzer v7.
