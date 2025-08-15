import Foundation

final class FavoriteDevicesRepository: FavoriteDevicesRepositoryType {

    init() {}

    func fetchFavoriteDevices() async throws -> [Device] {
        return [
            Device(id: "1", name: "Name 1", nickname: "Nickname 1"),
            Device(id: "2", name: "Name 2", nickname: "Nickname 2")
        ]
    }
}
