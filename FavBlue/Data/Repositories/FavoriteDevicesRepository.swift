import Foundation

final actor FavoriteDevicesRepository: FavoriteDevicesRepositoryType {

    private var storage: [UUID: Favorite] = [:]
    private var continuations: [UUID: AsyncThrowingStream<[Favorite], Error>.Continuation] = [:]

    // MARK: - Lifecycle

    init() {
//        storage[UUID()] = Favorite(deviceId: UUID(), lastKnownName: "123", nickname: "Nickname")
    }

    deinit {
        for cont in continuations.values { cont.finish() }
    }

    // MARK: - Internal methods

    func favoritesStream() -> AsyncThrowingStream<[Favorite], Error> {
        AsyncThrowingStream { continuation in
            let id = UUID()
            self.addContinuation(id: id, continuation: continuation)
            continuation.yield(Array(storage.values))
            continuation.onTermination = { @Sendable _ in
                Task { await self.removeContinuation(id: id) }
            }
        }
    }

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) {
        let fav = Favorite(deviceId: deviceId, lastKnownName: lastKnownName, nickname: nickname)
        storage[deviceId] = fav
        broadcastCurrent()
    }

    func removeFavorite(deviceId: UUID) {
        storage.removeValue(forKey: deviceId)
        broadcastCurrent()
    }

    func setNickname(deviceId: UUID, nickname: String?) {
        guard var existing = storage[deviceId] else { return }
        existing.nickname = nickname
        storage[deviceId] = existing
        broadcastCurrent()
    }

    // MARK: - Private methods

    private func addContinuation(
        id: UUID,
        continuation: AsyncThrowingStream<[Favorite], Error>.Continuation
    ) {
        continuations[id] = continuation
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func broadcastCurrent() {
        let snapshot = Array(storage.values)
        for cont in continuations.values { cont.yield(snapshot) }
    }
}
