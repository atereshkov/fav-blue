import Foundation
import CoreBluetooth

final class BluetoothScanner: NSObject {

    enum Event {
        case discovered(peripheral: CBPeripheral, rssi: NSNumber) // TODO: Model for discovered device
        case stateChanged(BluetoothScanState) // TODO: Should ideally not use any models from Domain
    }

    private var centralManager: CBCentralManager!
    private var continuation: AsyncStream<Event>.Continuation?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    deinit {
        print("BluetoothScanner deinit")
    }

    // MARK: - Internal methods

    func eventStream() -> AsyncStream<Event> {
        AsyncStream { continuation in
            self.continuation = continuation

            continuation.yield(.stateChanged(map(cbState: self.centralManager.state)))

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
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
            continuation?.yield(.stateChanged(.scanning))
        } else {
            continuation?.yield(.stateChanged(map(cbState: centralManager.state)))
        }
    }

    func stopScanning() {
        centralManager.stopScan()
        continuation?.yield(.stateChanged(map(cbState: centralManager.state)))
    }

    // MARK: - Private methods

    private func map(cbState: CBManagerState) -> BluetoothScanState {
        switch cbState {
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .unauthorized: return .unauthorized
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        @unknown default:
            return .unknown
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        continuation?.yield(.stateChanged(map(cbState: central.state)))

        switch central.state {
        case .poweredOn:
            startScanning()
        default:
            stopScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        continuation?.yield(.discovered(peripheral: peripheral, rssi: RSSI))
    }
}
