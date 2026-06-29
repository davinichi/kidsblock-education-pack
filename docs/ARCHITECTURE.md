# Architecture Notes

KidsBlock appears to use user data under:

`%APPDATA%\KidsBlock\Data\external-resources`

Important areas:

- `devices/device.js`: device ID list
- `devices/<device>/index.js`: device metadata
- `extensions/arduino/kit/<extension>/index.js`: Arduino kit extension metadata

A visible device likely requires matching IDs across these files.
