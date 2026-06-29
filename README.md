# KidsBlock SDK v1.0 RC3

RC3 is a broader verification patch.

It replaces all `esp32:esp32:esp32` occurrences in bundled JavaScript files inside `app.asar` with:

```text
esp32:esp32:XIAO_ESP32C3
```

It also provides Analyzer v13 to verify the active `app.asar` after patching.
