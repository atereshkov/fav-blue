import Foundation

protocol BluetoothScannerUseCaseType {
    func devicesStream(sortedBy option: DeviceSortOption) -> AsyncStream<[BluetoothDevice]>
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

    func devicesStream(sortedBy option: DeviceSortOption) -> AsyncStream<[BluetoothDevice]> {
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
                switch option {
                case .byNameThenRssi:
                    combined.sort(by: sortByNameRssiId)
                case .byRssiOnly:
                    combined.sort { $0.rssi > $1.rssi }
                case .custom(let comparator):
                    combined.sort(by: comparator)
                }
                continuation.yield(combined)
            }

            let devicesTask = Task {
                for await devices in repository.devicesStream() {
                    latestDevicesById = Dictionary(uniqueKeysWithValues: devices.map { ($0.id, $0) })
                    emitCombined()
                }
                continuation.finish()
            }

            let favsTask = Task {
                do {
                    for try await favs in await favoritesRepository.favoritesStream() {
                        latestFavoritesById = Dictionary(uniqueKeysWithValues: favs.map { ($0.deviceId, $0) })
                        emitCombined()
                    }
                    continuation.finish()
                } catch {
                    if error is CancellationError { return }
                    // TODO Ideally, log / throw error
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

    // MARK: - Private

    private let sortByNameRssiId: (BluetoothDevice, BluetoothDevice) -> Bool = { lhs, rhs in
        switch (lhs.name, rhs.name) {
        case let (l?, r?): // both have names
            if l != r {
                return l < r
            } else if lhs.rssi != rhs.rssi {
                return lhs.rssi > rhs.rssi
            } else {
                return lhs.id < rhs.id
            }
        case (nil, nil): // both don't have names
            if lhs.rssi != rhs.rssi {
                return lhs.rssi > rhs.rssi
            } else {
                return lhs.id < rhs.id
            }
        case (nil, _?): // left has no name, right has one -> right first
            return false
        case (_?, nil):
            return true // left has a name, right has none -> left first
        }
    }
}
