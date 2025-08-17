import Foundation

protocol BluetoothScannerUseCaseType {
    func devicesStream() -> AsyncStream<[BluetoothDevice]>
    func stateStream() -> AsyncStream<BluetoothScanState>

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

    func devicesStream() -> AsyncStream<[BluetoothDevice]> {
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
                combined.sort { $0.id > $1.id }
                continuation.yield(combined)
            }

            let devicesTask = Task {
                for await devices in repository.devicesStream() {
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

    func stateStream() -> AsyncStream<BluetoothScanState> {
        repository.stateStream()
    }

    func startScanning() {
        repository.startScanning()
    }

    func stopScanning() {
        repository.stopScanning()
    }
}
