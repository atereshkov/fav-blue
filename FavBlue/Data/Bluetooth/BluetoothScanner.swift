import Foundation
import CoreBluetooth

protocol BluetoothScannerType {
    func eventStream() -> AsyncStream<BluetoothScannerEvent>

    func startScanning()
    func stopScanning()
}

final class BluetoothScanner: NSObject, BluetoothScannerType {

    private var centralManager: CBCentralManager!
    private var continuation: AsyncStream<BluetoothScannerEvent>.Continuation?

    // MARK: - Lifecycle

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    deinit {
        continuation?.finish()
    }

    // MARK: - Internal methods

    func eventStream() -> AsyncStream<BluetoothScannerEvent> {
        AsyncStream { continuation in
            self.continuation = continuation

            continuation.yield(.stateChanged(.from(self.centralManager.state)))

            continuation.onTermination = { _ in
                self.stopScanning()
                self.continuation = nil
            }
        }
    }

    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: nil,
                options: nil
            )
            continuation?.yield(.stateChanged(.scanning))
        } else {
            continuation?.yield(.stateChanged(.from(centralManager.state)))
        }
    }

    func stopScanning() {
        centralManager.stopScan()
        continuation?.yield(.stateChanged(.from(centralManager.state)))
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        continuation?.yield(.stateChanged(.from(central.state)))

        switch central.state {
        case .unknown:
            stopScanning()
        case .resetting:
            stopScanning()
        case .unsupported:
            stopScanning()
        case .unauthorized:
            stopScanning()
        case .poweredOff:
            stopScanning()
        case .poweredOn:
            startScanning()
        @unknown default:
            stopScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = peripheral.identifier
        let name = peripheral.name
        let rssi = RSSI.intValue
        continuation?.yield(.discovered(id: id, name: name, rssi: rssi))
    }
}
