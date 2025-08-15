import Foundation

enum FavoriteDevicesState {
    case loading
    case loaded
    case error(Error?)
}
