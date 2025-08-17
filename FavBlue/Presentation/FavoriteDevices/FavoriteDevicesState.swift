import Foundation

enum FavoriteDevicesState {
    case loading
    case empty
    case loaded
    case error(Error?)
}
