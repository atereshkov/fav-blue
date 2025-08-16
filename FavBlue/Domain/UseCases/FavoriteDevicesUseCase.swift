import Foundation

protocol FavoriteDevicesUseCaseType {
    func favoriteDevices() -> AsyncStream<[Favorite]>
}

final class FavoriteDevicesUseCase: FavoriteDevicesUseCaseType {

    private let repository: FavoriteDevicesRepositoryType

    init(repository: FavoriteDevicesRepositoryType) {
        self.repository = repository
    }

    // MARK: - Internal methods

    func favoriteDevices() -> AsyncStream<[Favorite]> {
        repository.favoritesStream()
    }
}
