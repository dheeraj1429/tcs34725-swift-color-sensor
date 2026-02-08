import CoreBluetooth

/// A protocol for managing and monitoring Bluetooth Low Energy (BLE) device connections and states.
protocol BLEManagerDelegate {
    /// Indicates whether a device connection is in progress.
    var isConnecting: Bool { get set }
    /// Indicates whether BLE scanning is currently active.
    var isScanning: Bool { get set }
    /// Indicates whether the Bluetooth hardware is powered on and available.
    var isPowerOn: Bool { get set }
    /// Stores the last error message encountered during device disconnection.
    var disconnectionErrorMessage: String? { get set }
    /// Stores the last error message encountered during device connection.
    var connectionErrorMessage: String? { get set }
    /// List of discovered BLE peripherals during scanning.
    var discoverDevices: [CBPeripheral] { get set }
    /// The currently connected BLE peripheral, if any.
    var connectedDevice: CBPeripheral? { get set }
    /// The peripheral currently in the process of connecting, if any.
    var connectingDevice: CBPeripheral? { get set }
    /// Starts scanning for available BLE devices.
    func scanForDevices() -> ()
    /// Stops any ongoing BLE operations (such as scanning or connecting).
    func stop() -> ()
    /// Attempts to connect to the specified BLE peripheral.
    func connect(with peripheral: CBPeripheral) -> ()
    /// Disconnects from the specified BLE peripheral.
    func disconnect(to peripheral: CBPeripheral) -> ()
    /// Checks if the specified peripheral is in the process of connecting.
    func isDeviceConnecting(with peripheral: CBPeripheral) -> Bool
    /// Checks if the specified peripheral is currently connected.
    func isDeviceConnected(with peripheral: CBPeripheral) -> Bool
}
