import Combine
import Foundation
import CoreBluetooth
import SwiftUI

final class BLEManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    static let shared = BLEManager()
    
    private var centralManager: CBCentralManager?
    private var timer: Timer?
    
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
        centralManager.scanForPeripherals(withServices: [])
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
