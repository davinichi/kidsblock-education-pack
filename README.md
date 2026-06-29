# KidsBlock SDK v0.9

## Purpose

Locate the real `2.bundle.js` used by KidsBlock and identify where `esp32:esp32:esp32` is still being used.

The previous test proved that changing the external-resources kit file was not enough.  
The uploaded `2.bundle.js` contains the actual ESP32 FQBN definition.

This version is **read-only by default**. It only searches and reports candidate bundle files.
