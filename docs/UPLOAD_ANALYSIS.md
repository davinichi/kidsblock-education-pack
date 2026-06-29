# Upload Analysis

## Current finding

KidsBlock 2.0.5 contains a built-in `arduinoEsp32` device extension. In the bundled JavaScript, its upload/build option is hardcoded as:

```js
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:esp32'
};
```

This explains the upload error for XIAO ESP32C3:

```text
This chip is ESP32-C3, not ESP32. Wrong --chip argument?
```

The first workaround tried in EP001 v0.8 modified `boards.txt`, but PowerShell wrote the file with a BOM. Arduino CLI then failed with:

```text
invalid line format
Invalid FQBN: board esp32:esp32:esp32 not found
```

## v0.5/v0.9 change

- Add safe restore script for v0.8.
- Rewrite `boards.txt` with UTF-8 without BOM.
- Keep the workaround experimental and reversible.
