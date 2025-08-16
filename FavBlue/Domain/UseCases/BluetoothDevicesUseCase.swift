import Foundation

protocol BluetoothDevicesUseCaseType {
    func devices() -> AsyncStream<[BluetoothDevice]>
    func state() -> AsyncStream<BluetoothScanState>

    func startScanning()
    func stopScanning()
}

final class BluetoothDevicesUseCase: BluetoothDevicesUseCaseType {

    private let repository: BluetoothDevicesRepositoryType

    init(repository: BluetoothDevicesRepositoryType) {
        self.repository = repository
    }

    // MARK: - Internal methods

    func devices() -> AsyncStream<[BluetoothDevice]> {
        repository.devices()
    }

    func state() -> AsyncStream<BluetoothScanState> {
        repository.state()
    }

    func startScanning() {
        repository.startScanning()
    }

    func stopScanning() {
        repository.stopScanning()
    }
}
