import Foundation

extension BluetoothScannerUseCaseType where Self == MockBluetoothScannerUseCase {
    static func previewMock() -> BluetoothScannerUseCaseType {
        MockBluetoothScannerUseCase()
    }
}

final class MockBluetoothScannerUseCase: BluetoothScannerUseCaseType {
    func devicesStream(sortedBy option: DeviceSortOption) -> AsyncStream<[BluetoothDevice]> {
        AsyncStream { continuation in
            let items = [
                BluetoothDevice(id: UUID(), name: "Name 1", rssi: -20),
                BluetoothDevice(id: UUID(), name: "Name 2", rssi: -50)
            ]
            continuation.yield(items)
        }
    }
    func stateStream() -> AsyncStream<BluetoothScanState> {
        .init(unfolding: { .scanning })
    }
    func startScanning() {}
    func stopScanning() {}
}
