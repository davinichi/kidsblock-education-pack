# Upload Analysis v0.9

## Current status

- Device list: OK
- Block screen: OK
- Compile: OK
- Upload: still uses ESP32, not ESP32-C3

## Key finding

The uploaded `2.bundle.js` contains:

```js
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:esp32'
};
```

This likely overrides or bypasses the kit-level FQBN settings.

## Next step

Find the real active `2.bundle.js` file used by KidsBlock.  
Do not patch the file until its full path is confirmed.
