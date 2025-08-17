import Foundation

protocol FavoriteDevicesRepositoryType {
    func favoritesStream() async -> AsyncThrowingStream<[Favorite], Error>

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async
    func removeFavorite(deviceId: UUID) async

    func setNickname(deviceId: UUID, nickname: String?) async
}
