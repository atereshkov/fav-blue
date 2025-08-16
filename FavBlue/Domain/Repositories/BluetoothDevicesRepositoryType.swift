import Foundation

protocol BluetoothDevicesRepositoryType {
    func devices() -> AsyncStream<[BluetoothDevice]>
    func state() -> AsyncStream<BluetoothScanState>

    func startScanning()
    func stopScanning()
}
