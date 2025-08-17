import Foundation

@MainActor
@Observable
final class ScanDevicesViewModel {

    private let useCase: BluetoothScannerUseCaseType
    private let favoritesUseCase: FavoriteDevicesUseCaseType

    private(set) var devices: [BluetoothDevice] = []
    private(set) var state: ScanDevicesState = .scanning
    private(set) var activeDialog: FavoriteDialog?

    private var devicesTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init(
        useCase: BluetoothScannerUseCaseType,
        favoritesUseCase: FavoriteDevicesUseCaseType
    ) {
        self.useCase = useCase
        self.favoritesUseCase = favoritesUseCase
    }

    deinit {
        print("ScanDevicesViewModel deinit")
    }

    // MARK: - Internal methods

    func start() {
        useCase.startScanning()

        devicesTask = Task { [weak self] in
            guard let self = self else { return }
            for await list in useCase.devicesStream() {
                self.devices = list
//                    .map { FavoriteDeviceViewItem(name: $0.name ?? "") }
            }
        }

        stateTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in useCase.stateStream() {
                self.state = map(scannerState: state)
            }
        }
    }

    func stop() {
        useCase.stopScanning()
        devicesTask?.cancel()
        stateTask?.cancel()
    }

    func handleDeviceTap(_ device: BluetoothDevice) {
        if device.isFavorite {
            activeDialog = .remove(device: device)
        } else {
            activeDialog = .add(device: device)
        }
    }

    // MARK: - Private methods

    func addFavorite(_ device: BluetoothDevice, nickname: String?) {
        let lastKnownName = device.name
        Task {
            await favoritesUseCase.addFavorite(
                deviceId: device.id,
                lastKnownName: lastKnownName,
                nickname: nickname ?? lastKnownName
            )
        }
    }

    func removeFavorite(device: BluetoothDevice) {
        Task {
            await favoritesUseCase.removeFavorite(deviceId: device.id)
        }
    }

    func dismissDialog() {
        activeDialog = nil
    }

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
