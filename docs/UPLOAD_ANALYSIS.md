# Upload Analysis v1.0 RC2

The resent `bundle.zip` was inspected.

It contains `bundle.txt`, and the relevant section is:

```js
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:esp32'
};
```

This confirms that the upload problem is caused by the bundled ESP32 device definition still using the generic ESP32 FQBN.

RC2 patches the extracted `app.asar` bundle by replacing only this device-option block with the XIAO ESP32C3 FQBN.

Target replacement:

```text
esp32:esp32:esp32
↓
esp32:esp32:XIAO_ESP32C3
```
