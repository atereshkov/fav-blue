import Foundation

protocol BluetoothScannerRepositoryType {
    func devicesStream() -> AsyncStream<[BluetoothDevice]>
    func stateStream() -> AsyncStream<BluetoothScanState>

    func startScanning()
    func stopScanning()
}
