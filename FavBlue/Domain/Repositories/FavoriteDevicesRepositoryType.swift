import Foundation

protocol FavoriteDevicesRepositoryType {
    func favoritesStream() -> AsyncStream<[Favorite]>

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?)
    func removeFavorite(deviceId: UUID)

    func setNickname(deviceId: UUID, nickname: String?)
}
