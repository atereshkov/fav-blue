import Foundation

protocol FavoriteDevicesUseCaseType {
    func fetchFavoriteDevices() async throws -> [BluetoothDevice]
}

final class FavoriteDevicesUseCase: FavoriteDevicesUseCaseType {

    private let repository: FavoriteDevicesRepositoryType

    init(repository: FavoriteDevicesRepositoryType) {
        self.repository = repository
    }

    // MARK: - Internal methods

    func fetchFavoriteDevices() async throws -> [BluetoothDevice] {
        return try await repository.fetchFavoriteDevices()
    }
}
