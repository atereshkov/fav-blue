import Foundation

final class BluetoothScannerRepository: BluetoothScannerRepositoryType {

    private let bluetoothScanner: BluetoothScannerType

    private var devicesContinuation: AsyncStream<[BluetoothDevice]>.Continuation?
    private var stateContinuation: AsyncStream<BluetoothScanState>.Continuation?

    private var devicesById: [UUID: BluetoothDevice] = [:]
    private var consumerTask: Task<Void, Never>?

    // MARK: Lifecycle

    init(bluetoothScanner: BluetoothScannerType) {
        self.bluetoothScanner = bluetoothScanner

        setupConsumer()
    }

    deinit {
        consumerTask?.cancel()
        devicesContinuation?.finish()
        stateContinuation?.finish()
    }

    // MARK: - Internal methods

    func devicesStream() -> AsyncStream<[BluetoothDevice]> {
        AsyncStream { continuation in
            self.devicesContinuation = continuation
            continuation.yield(Array(self.devicesById.values))
            continuation.onTermination = { _ in
                self.devicesContinuation = nil
            }
        }
    }

    func stateStream() -> AsyncStream<BluetoothScanState> {
        AsyncStream { continuation in
            self.stateContinuation = continuation
            continuation.yield(.idle)
            continuation.onTermination = { _ in
                self.stateContinuation = nil
            }
        }
    }

    func startScanning() {
        bluetoothScanner.startScanning()
        stateContinuation?.yield(.scanning)
    }

    func stopScanning() {
        bluetoothScanner.stopScanning()
        stateContinuation?.yield(.idle)
    }

    // MARK: - Private methods

    private func setupConsumer() {
        consumerTask = Task { [weak self] in
            guard let self else { return }
            for await event in self.bluetoothScanner.eventStream() {
                switch event {
                case .stateChanged(let state):
                    self.stateContinuation?.yield(state.toDomain())
                case .discovered(let id, let name, let rssi):
                    if var existing = self.devicesById[id] {
                        existing.update(name: name, rssi: rssi)
                        self.devicesById[id] = existing
                    } else {
                        let newDevice = BluetoothDevice(id: id, name: name, rssi: rssi)
                        self.devicesById[id] = newDevice
                    }
                    let devices = Array(self.devicesById.values)
                    self.devicesContinuation?.yield(devices)
                }
            }
        }
    }
}
