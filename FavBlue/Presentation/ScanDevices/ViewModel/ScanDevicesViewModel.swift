import Foundation

@MainActor
@Observable
final class ScanDevicesViewModel {

    private let useCase: BluetoothScannerUseCaseType
    private let favoritesUseCase: FavoriteDevicesUseCaseType

    private(set) var devices: [BluetoothDevice] = []
    private(set) var state: ScanDevicesState = .scanning
    private(set) var activeAlert: ScanDeviceAlert?
    private(set) var activeSheet: ScanDeviceSheet?

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

    // MARK: - Internal methods

    func start() {
        useCase.startScanning()

        devicesTask = Task { [weak self] in
            guard let self else { return }
            for await list in useCase.devicesStream(sortedBy: .byNameThenRssi) {
                self.devices = list
            }
        }

        stateTask = Task { [weak self] in
            guard let self else { return }
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
            activeAlert = .remove(device: device)
        } else {
            activeSheet = .addToFavorites(device: device)
        }
    }

    // MARK: - Private methods

    func addFavorite(_ device: BluetoothDevice, nickname: String?) {
        Task {
            await favoritesUseCase.addFavorite(
                deviceId: device.id,
                lastKnownName: device.name,
                nickname: nickname ?? device.name
            )
        }
    }

    func removeFavorite(device: BluetoothDevice) {
        Task {
            await favoritesUseCase.removeFavorite(deviceId: device.id)
        }
    }

    func dismissAlert() {
        activeAlert = nil
    }

    func dismissSheet() {
        activeSheet = nil
    }

    // MARK: - Private methods

    private func map(scannerState: BluetoothScanState) -> ScanDevicesState {
        switch scannerState {
        case .idle: return .idle(message: "Warming up..")
        case .poweredOn: return .idle(message: nil)
        case .scanning: return .scanning
        case .poweredOff: return .idle(message: "Make sure to turn on Bluetooth in device settings.")
        case .unsupported: return .error(.unsupported)
        case .unauthorized: return .error(.unauthorized)
        case .resetting: return .error(.resetting)
        case .unknown: return .error(.unknown)
        case .error: return .error(.unknown)
        }
    }
}
