import Combine
import Foundation
import CoreBluetooth
import SwiftUI

enum Command: UInt8 {
    case scan = 0
}

enum SensorEvent {
    case colorSensorReadingEvent(data: SensorColorResponse)
}

struct ColorSensorConfig {
    static let colorServiceUUID = CBUUID(string: "57ef795b-76cf-41f0-96d3-a7fa66c8da76")
    static let colorCharUUID = CBUUID(string: "ae38c1be-6615-4461-9074-63b82a5457e4")
}

struct SensorColorResponse: Codable {
    let r: Double, g: Double, b: Double, c: Double, lux: Double
    
    var displayColor: Color {
        Color(
            red: r,
            green: g,
            blue: b
        )
    }
}

final class BLEManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    static let shared = BLEManager()
    
    private var centralManager: CBCentralManager?
    private var timer: Timer?
    
    var eventPublisher = PassthroughSubject<SensorEvent, Never>()
    
    @Published var isPowerOn: Bool = false
    @Published var isScanning: Bool = false
    @Published var isConnecting: Bool = false
    
    @Published var disconnectionErrorMessage: String?
    @Published var connectionErrorMessage: String?
    
    @Published var discoverDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var connectingDevice: CBPeripheral?
    
    var shouldPresentErrorAlert: Binding<Bool> {
        Binding {
            self.connectionErrorMessage != nil || self.disconnectionErrorMessage != nil
        } set: { newValue in
            if newValue {
                if self.connectionErrorMessage != nil {
                    self.connectionErrorMessage = nil
                } else {
                    self.disconnectionErrorMessage = nil
                }
            }
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager: BLEManagerDelegate {
    func scanForDevices() {
        guard let centralManager else {
            print("Central manager not available!")
            return
        }
        
        if centralManager.state != .poweredOn {
            print("Bluetooth is not powered on!")
            return
        }
        
        isScanning = true
        centralManager.scanForPeripherals(withServices: [ColorSensorConfig.colorServiceUUID])
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            self.stop()
        })
        print("Start scanning for peripherals....")
    }
    
    func stop() {
        guard let centralManager else {
            print("Central manager not available!")
            return
        }
        
        isScanning = false
        centralManager.stopScan()
        if let timer {
            timer.invalidate()
        }
        print("Stop scanning....")
    }
    
    func connect(with peripheral: CBPeripheral) {
        guard let centralManager else { return }
        
        isConnecting = true
        connectingDevice = peripheral
        connectedDevice = nil
        
        centralManager.connect(peripheral, options: nil)
    }
    
    func isDeviceConnected(with peripheral: CBPeripheral) -> Bool {
        guard let connectedDevice else { return false }
        
        return connectedDevice.identifier == peripheral.identifier
    }
    
    func isDeviceConnecting(with peripheral: CBPeripheral) -> Bool {
        guard isConnecting else { return false }
        guard let connectingDevice else { return false }
        return isConnecting && connectingDevice.identifier == peripheral.identifier
    }
    
    func disconnect(to peripheral: CBPeripheral) {
        guard let centralManager else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(peripheral.name ?? "Unknown name")")
    }
    
    func findCBCharacteristic(on peripheral: CBPeripheral, withCharUUId: CBUUID, withServiceUUID: CBUUID) -> CBCharacteristic? {
        guard let services = peripheral.services else {
            print("Peripheral services not found...")
            return nil
        }
        
        guard let service = services.first(where: { $0.uuid == withServiceUUID }) else {
            return nil
        }
        print("Found service: \(String(describing: service))")
        guard let characteristics = service.characteristics else { return nil }
        return characteristics.first(where: { $0.uuid == withCharUUId })
        
    }
    
    func sendCommand(with command: Command) {
        guard let connectedDevice else {
            print("No connected device found")
            return
        }
        
        let data = Data([command.rawValue])
        print("Command \(command) sent")
        guard let cBCharacteristic = findCBCharacteristic(
            on: connectedDevice,
            withCharUUId: ColorSensorConfig.colorCharUUID,
            withServiceUUID: ColorSensorConfig.colorServiceUUID
        ) else {
            print("cBCharacteristic not found...")
            return
        }
        connectedDevice.writeValue(data, for: cBCharacteristic, type: .withResponse)
    }
}

extension BLEManager {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            DispatchQueue.main.async {
                self.isPowerOn = true
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            print("Found device: \(peripheral.name ?? "Unknown name")")
            if !self.discoverDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                self.discoverDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print("Connected to \(peripheral.name ?? "Unknown name")")
            self.isConnecting = false
            self.connectingDevice = nil
            self.connectedDevice = peripheral
            self.stop()
            
            peripheral.delegate = self
            peripheral.discoverServices([ColorSensorConfig.colorServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            connectionErrorMessage = "Error: during the connection with \(peripheral.name ?? "Known name") with error: \(error.localizedDescription)"
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            disconnectionErrorMessage = "Error: during disconnecting from the \(peripheral.name ?? "Known name") with error: \(error.localizedDescription)"
            return
        }
        
        DispatchQueue.main.async {
            self.connectedDevice = nil
            self.isConnecting = false
            self.scanForDevices()
        }
    }
}


extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error {
            print("Error: during discovering the services \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("Services not found...")
            return
        }
        
        for service in services {
            print("Discover service uuid: \(service.uuid)")
            peripheral.discoverCharacteristics([ColorSensorConfig.colorCharUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error {
            print("Error: during discovering characteristics \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("Characteristics not found...")
            return
        }
        
        for characteristic in characteristics {
            print("Discover characteristic uuid: \(characteristic.uuid)")
            if characteristic.uuid.uuidString.lowercased() == ColorSensorConfig.colorCharUUID.uuidString.lowercased() {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Found color service characteristic uuid: \(characteristic.uuid.uuidString) and set the notification enable..")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            print("Error: during reading the characteristic value \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let formattedData = try decoder.decode(SensorColorResponse.self, from: value)
            DispatchQueue.main.async {
                self.eventPublisher.send(.colorSensorReadingEvent(data: formattedData))
            }
        } catch {
            print("Error: during decoding the data: \(error.localizedDescription)")
        }
    }
}
