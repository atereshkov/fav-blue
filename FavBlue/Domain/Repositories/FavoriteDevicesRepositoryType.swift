import Foundation

protocol FavoriteDevicesRepositoryType {
    func fetchFavoriteDevices() async throws -> [BluetoothDevice]
}
