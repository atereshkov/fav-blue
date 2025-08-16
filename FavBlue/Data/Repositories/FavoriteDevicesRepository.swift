import Foundation

final class FavoriteDevicesRepository: FavoriteDevicesRepositoryType {

    init() {}

    func fetchFavoriteDevices() async throws -> [BluetoothDevice] {
        return [
            BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50),
            BluetoothDevice(id: UUID(), name: "Name 2", rssi: -20),
        ]
    }
}
