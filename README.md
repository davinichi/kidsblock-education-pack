# KidsBlock Education Pack SDK v0.3

This repository contains tools and draft Education Packs for extending KidsBlock.

## v0.3 focus

- Confirmed KidsBlock device loader structure.
- Added Analyzer v5 for nested device-folder checks.
- Added EP001 XIAO ESP32C3 display-only installer draft v0.7.

## Important discovery

KidsBlock loads devices with this structure:

```text
external-resources/
  devices/
    device.js
    <catalog>/
      <device>/
        index.js
```

Therefore a device folder must not be installed directly as:

```text
devices/XIAOESP32C3/index.js
```

It must be installed as:

```text
devices/XIAOESP32C3/XIAOESP32C3/index.js
```

