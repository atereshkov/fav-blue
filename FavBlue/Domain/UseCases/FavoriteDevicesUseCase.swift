import Foundation

protocol FavoriteDevicesUseCaseType {
    func fetchFavoriteDevices() async throws -> [Device]
}

final class FavoriteDevicesUseCase: FavoriteDevicesUseCaseType {

    private let repository: FavoriteDevicesRepositoryType

    init(repository: FavoriteDevicesRepositoryType) {
        self.repository = repository
    }

    func fetchFavoriteDevices() async throws -> [Device] {
        return try await repository.fetchFavoriteDevices()
    }
}
