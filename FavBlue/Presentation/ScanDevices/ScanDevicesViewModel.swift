import Foundation

@MainActor
@Observable
final class ScanDevicesViewModel {

    private(set) var devices: [BluetoothDevice] = []
    private(set) var state: ScanDevicesState = .scanning

    private let useCase: BluetoothDevicesUseCaseType
    // TODO: Add favorites usecase as well

    private var devicesTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init(useCase: BluetoothDevicesUseCaseType) {
        self.useCase = useCase
    }

    deinit {
        print("ScanDevicesViewModel deinit")
    }

    // MARK: - Internal methods

    func start() {
        useCase.startScanning()

        devicesTask = Task { [weak self] in
            guard let self = self else { return }
            for await list in useCase.devices() {
                // TODO: Merge with favorite devices - update model (isFavorite, nickname)
                self.devices = list
//                    .map { FavoriteDeviceViewItem(name: $0.name ?? "") }
            }
        }

        stateTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in useCase.state() {
                self.state = map(scannerState: state)
            }
        }
    }

    func stop() {
        useCase.stopScanning()
        devicesTask?.cancel()
        stateTask?.cancel()
    }

    // MARK: - Private methods

    private func map(scannerState: BluetoothScanState) -> ScanDevicesState {
        switch scannerState {
        case .idle: return .idle
        case .poweredOn: return .idle
        case .scanning: return .scanning
        case .poweredOff: return .idle
        case .unsupported: return .error(nil) // TODO: Pass errors or localized strings
        case .unauthorized: return .error(nil)
        case .resetting: return .error(nil)
        case .unknown: return .error(nil)
        case .error: return .error(nil)
        }
    }
}
