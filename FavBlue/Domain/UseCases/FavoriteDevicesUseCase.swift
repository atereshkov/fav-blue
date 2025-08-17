import Foundation

protocol FavoriteDevicesUseCaseType {
    func favoriteDevices() async -> AsyncStream<[Favorite]>

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async
    func removeFavorite(deviceId: UUID) async
    func setNickname(deviceId: UUID, nickname: String?) async
}

final class FavoriteDevicesUseCase: FavoriteDevicesUseCaseType {

    private let repository: FavoriteDevicesRepositoryType

    init(repository: FavoriteDevicesRepositoryType) {
        self.repository = repository
    }

    // MARK: - Internal methods

    func favoriteDevices() async -> AsyncStream<[Favorite]> {
        await repository.favoritesStream()
    }

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async {
        await repository.addFavorite(deviceId: deviceId, lastKnownName: lastKnownName, nickname: nickname)
    }

    func removeFavorite(deviceId: UUID) async {
        await repository.removeFavorite(deviceId: deviceId)
    }

    func setNickname(deviceId: UUID, nickname: String?) async {
        await repository.setNickname(deviceId: deviceId, nickname: nickname)
    }
}
