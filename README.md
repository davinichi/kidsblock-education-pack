# KidsBlock SDK v0.5

This version fixes the v0.8 boards.txt encoding issue and adds a safer EP001 v0.9 upload alias test.

## Important

If v0.8 caused `invalid line format` or `Invalid FQBN`, run the safe restore first:

`packs/EP001_XIAO_ESP32C3/installer/restore_ep001_xiao_esp32c3_v0_8_safe.bat`

After normal ESP32 compile behavior is restored, test EP001 v0.9:

`packs/EP001_XIAO_ESP32C3/installer/install_ep001_xiao_esp32c3_v0_9.bat`
