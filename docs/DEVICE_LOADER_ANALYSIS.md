# Device Loader Analysis

## Confirmed source

`app.asar` contains `node_modules/openblock-resource/src/device.js`.

The relevant logic is:

1. Load all `index.js` files recursively under `external-resources/devices`.
2. Load `external-resources/devices/device.js`.
3. For each item in `device.js`, search the loaded device modules.
4. If `content.deviceId` equals the list item, the device is displayed with full metadata.
5. If no module matches, only `{deviceId: listItem}` is pushed.

## Required structure

```text
external-resources/devices/<catalog>/<device>/index.js
```

For ESP32S, the actual path is:

```text
external-resources/devices/ESP32S/ESP32S/index.js
```

So XIAO ESP32C3 display test must use:

```text
external-resources/devices/XIAOESP32C3/XIAOESP32C3/index.js
```

## EP001 v0.7 scope

EP001 v0.7 is display-only.

Goal:

- Add `XIAOESP32C3_arduinoEsp32` to `devices/device.js`.
- Add `devices/XIAOESP32C3/XIAOESP32C3/index.js`.
- Confirm that the device appears in KidsBlock.

Not guaranteed in v0.7:

- ESP32-C3 compile.
- Upload to XIAO ESP32C3.
- Correct esptool chip argument.

