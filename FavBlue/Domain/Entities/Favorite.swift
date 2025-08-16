import Foundation

struct Favorite: Equatable, Identifiable {
    let id = UUID()

    let deviceId: UUID
    var lastKnownName: String?
    var nickname: String?

    init(deviceId: UUID, lastKnownName: String?, nickname: String?) {
        self.deviceId = deviceId
        self.lastKnownName = lastKnownName
        self.nickname = nickname
    }
}
