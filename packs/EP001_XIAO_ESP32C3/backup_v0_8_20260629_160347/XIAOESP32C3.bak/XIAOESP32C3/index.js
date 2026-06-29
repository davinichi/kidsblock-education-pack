const XIAOESP32C3 = formatMessage => ({
    name: 'Seeed Studio XIAO ESP32C3',
    deviceId: 'XIAOESP32C3_arduinoEsp32',
    manufactor: 'Seeed Studio',
    leanMore: 'https://wiki.seeedstudio.com/XIAO_ESP32C3_Getting_Started/',
    description: formatMessage({
        id: 'XIAOESP32C3.description',
        default: 'Seeed Studio XIAO ESP32C3',
        description: 'Description for Seeed Studio XIAO ESP32C3'
    }),
    disabled: false,
    bluetoothRequired: false,
    serialportRequired: true,
    defaultBaudRate: '115200',
    pnpidList: null,
    internetConnectionRequired: false,
    launchPeripheralConnectionFlow: true,
    useAutoScan: false,
    programMode: ['upload'],
    programLanguage: ['block', 'cpp'],
    tags: ['arduino'],
    deviceExtensions: ['ESP32S'],
    deviceExtensionsCompatible: 'arduinoEsp32',
    helpLink: 'https://wiki.seeedstudio.com/XIAO_ESP32C3_Getting_Started/'
});

module.exports = XIAOESP32C3;
