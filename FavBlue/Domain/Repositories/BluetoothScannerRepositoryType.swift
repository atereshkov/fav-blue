import Foundation

protocol BluetoothScannerRepositoryType {
    func devices() -> AsyncStream<[BluetoothDevice]>
    func state() -> AsyncStream<BluetoothScanState>

    func startScanning()
    func stopScanning()
}
