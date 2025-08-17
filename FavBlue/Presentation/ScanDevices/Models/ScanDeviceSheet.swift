import Foundation

enum ScanDeviceSheet: Identifiable, Equatable {
    case addToFavorites(device: BluetoothDevice)

    var id: String {
        switch self {
        case .addToFavorites(let device): return device.id.uuidString
        }
    }
}
