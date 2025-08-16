import Foundation

final class BluetoothDevicesRepository: BluetoothDevicesRepositoryType {

    private let bluetoothScanner: BluetoothScanner

    private var devicesContinuation: AsyncStream<[BluetoothDevice]>.Continuation?
    private var stateContinuation: AsyncStream<BluetoothScanState>.Continuation?

    private var devicesById: [UUID: BluetoothDevice] = [:]
    private var consumerTask: Task<Void, Never>?

    // MARK: Lifecycle

    init(bluetoothScanner: BluetoothScanner) {
        self.bluetoothScanner = bluetoothScanner

        setupConsumer()
    }

    deinit {
        consumerTask?.cancel()
        devicesContinuation?.finish()
        stateContinuation?.finish()
    }

    // MARK: - Internal methods

    func devices() -> AsyncStream<[BluetoothDevice]> {
        AsyncStream { continuation in
            self.devicesContinuation = continuation
            // TODO: Move out sorting to usecase lvl?
            continuation.yield(Array(self.devicesById.values).sorted(by: { $0.name ?? "" > $1.name ?? "" }))
            continuation.onTermination = { _ in
                self.devicesContinuation = nil
            }
        }
    }

    func state() -> AsyncStream<BluetoothScanState> {
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
            guard let self = self else { return }
            for await event in self.bluetoothScanner.eventStream() {
                switch event {
                case .stateChanged(let state):
                    self.stateContinuation?.yield(state)
                case .discovered(let peripheral, let rssi):
                    let id = peripheral.identifier
                    if var existing = self.devicesById[id] {
                        existing.update(name: peripheral.name, rssi: rssi)
                        self.devicesById[id] = existing
                    } else {
                        let newDevice = BluetoothDevice(id: id, name: peripheral.name, rssi: rssi)
                        self.devicesById[id] = newDevice
                    }
                    // TODO: Remove sorting?
                    let sorted = Array(self.devicesById.values)
                        .sorted { ($0.name ?? "") > ($1.name ?? "") }
                    self.devicesContinuation?.yield(sorted)
                }
            }
        }
    }
}
