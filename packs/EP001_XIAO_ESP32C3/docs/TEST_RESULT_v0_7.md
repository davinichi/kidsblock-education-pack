# EP001 XIAO ESP32C3 v0.7 test result

## Result

- Device list display: OK
- Block editor opens: OK
- Simple Arduino code generation: OK
- Compile: OK
- Upload: NG

## Upload error

```text
A fatal error occurred: This chip is ESP32-C3, not ESP32. Wrong --chip argument?
Failed uploading: uploading error: exit status 2
Failed to flash (exit code: 1)
```

## Conclusion

The device registration path is correct. The next milestone is correcting the upload target from ESP32 to ESP32-C3.
