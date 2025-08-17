import Foundation

enum FavoriteDevicesDialog: Equatable {
    case remove(device: Favorite)

    var message: String {
        switch self {
        case .remove(let favorite):
            "Remove \(favorite.nickname ?? favorite.lastKnownName ?? "") from favorites?"
        }
    }

    var alertTitle: String {
        switch self {
        case .remove(_):
            "Confirm"
        }
    }
}
