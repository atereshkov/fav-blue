import Foundation

enum FavoriteDevicesSheet: Identifiable, Equatable {
    case changeNickname(device: Favorite)

    var id: String {
        switch self {
        case .changeNickname(let favorite): return favorite.id.uuidString
        }
    }
}
