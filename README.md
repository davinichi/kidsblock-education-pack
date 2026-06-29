# KidsBlock SDK v1.0 RC2

## Purpose

Patch the confirmed bundled ESP32 device definition that contains:

```js
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:esp32'
};
```

to use the ESP32-C3 FQBN:

```text
esp32:esp32:XIAO_ESP32C3
```

This is a functional test for EP001 XIAO ESP32C3 upload.

## Important

- Close KidsBlock before running the installer.
- This test may temporarily affect the normal ESP32 device, because it patches the bundled ESP32 definition.
- A restore script is included.
- Node.js / npx is required because the script uses `npx asar`.
