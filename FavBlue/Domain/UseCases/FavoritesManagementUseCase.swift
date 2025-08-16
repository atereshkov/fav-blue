import Foundation

protocol FavoritesManagementUseCaseType {
    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async
    func removeFavorite(deviceId: UUID) async
    func setNickname(deviceId: UUID, nickname: String?) async
}

final class FavoritesManagementUseCase: FavoritesManagementUseCaseType {

    private let repository: FavoriteDevicesRepositoryType

    init(repository: FavoriteDevicesRepositoryType) {
        self.repository = repository
    }

    // MARK: - Internal methods

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
