import Foundation

protocol BluetoothScannerUseCaseType {
    func devices() -> AsyncStream<[BluetoothDevice]>
    func state() -> AsyncStream<BluetoothScanState>

    func startScanning()
    func stopScanning()
}

final class BluetoothScannerUseCase: BluetoothScannerUseCaseType {

    private let repository: BluetoothScannerRepositoryType
    private let favoritesRepository: FavoriteDevicesRepositoryType

    init(
        repository: BluetoothScannerRepositoryType,
        favoritesRepository: FavoriteDevicesRepositoryType
    ) {
        self.repository = repository
        self.favoritesRepository = favoritesRepository
    }

    // MARK: - Internal methods

    func devices() -> AsyncStream<[BluetoothDevice]> {
//        return repository.devices()

        // TODO: Figure out some weird UI updates
        AsyncStream { continuation in
            var latestDevicesById: [UUID: BluetoothDevice] = [:]
            var latestFavoritesById: [UUID: Favorite] = [:]

            func emitCombined() {
                var combined = latestDevicesById.values.map { (device) -> BluetoothDevice in
                    var result = device
                    if let fav = latestFavoritesById[device.id] {
                        result.isFavorite = true
                        result.nickname = fav.nickname
                    } else {
                        result.isFavorite = false
                        result.nickname = nil
                    }
                    return result
                }
                combined.sort { ($0.name ?? "") > ($1.name ?? "") }
                continuation.yield(combined)
            }

            let devicesTask = Task {
                for await devices in repository.devices() {
                    latestDevicesById = Dictionary(uniqueKeysWithValues: devices.map { ($0.id, $0) })
                    emitCombined()
                }
            }

            let favsTask = Task {
                for await favs in await favoritesRepository.favoritesStream() {
                    latestFavoritesById = Dictionary(uniqueKeysWithValues: favs.map { ($0.deviceId, $0) })
                    emitCombined()
                }
            }

            continuation.onTermination = { @Sendable _ in
                devicesTask.cancel()
                favsTask.cancel()
            }
        }

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
