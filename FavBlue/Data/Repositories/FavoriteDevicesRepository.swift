import Foundation

final class FavoriteDevicesRepository: FavoriteDevicesRepositoryType {

    private var storage: [UUID: Favorite] = [:]
    private var continuation: AsyncStream<[Favorite]>.Continuation?

    init() {
        storage[UUID()] = Favorite(deviceId: UUID(), lastKnownName: "123", nickname: "Nickname")
    }

    func favoritesStream() -> AsyncStream<[Favorite]> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(Array(storage.values))
            continuation.onTermination = { @Sendable _ in
                self.continuation = nil
            }
        }
    }

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) {
        let fav = Favorite(deviceId: deviceId, lastKnownName: lastKnownName, nickname: nickname)
        storage[deviceId] = fav
        continuation?.yield(Array(storage.values))
    }

    func removeFavorite(deviceId: UUID) {
        storage.removeValue(forKey: deviceId)
        continuation?.yield(Array(storage.values))
    }

    func setNickname(deviceId: UUID, nickname: String?) {
        guard var existing = self.storage[deviceId] else { return }
        existing.nickname = nickname
        storage[deviceId] = existing
        continuation?.yield(Array(storage.values))
    }
}
