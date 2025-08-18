import Foundation

enum FavoriteDevicesAlert: Equatable {
    case remove(device: Favorite)

    var message: String {
        switch self {
        case .remove(let favorite):
            "Remove \(favorite.userFacingName) from favorites?"
        }
    }

    var title: String {
        switch self {
        case .remove(_):
            "Confirm"
        }
    }
}
