import Foundation

extension FavoriteDevicesUseCaseType where Self == MockFavoriteDevicesUseCase {
    static func previewMock() -> FavoriteDevicesUseCaseType {
        MockFavoriteDevicesUseCase()
    }
}

final class MockFavoriteDevicesUseCase: FavoriteDevicesUseCaseType {
    func favoriteDevices() async -> AsyncThrowingStream<[Favorite], any Error> {
        AsyncThrowingStream { continuation in
            let items = [
                Favorite(deviceId: UUID(), lastKnownName: "Known 1", nickname: "Nick 1"),
                Favorite(deviceId: UUID(), lastKnownName: "Known 2", nickname: nil),
            ]
            continuation.yield(items)
        }
    }
    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async {}
    func removeFavorite(deviceId: UUID) async {}
    func setNickname(deviceId: UUID, nickname: String?) async {}
}
