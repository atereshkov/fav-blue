import Foundation

enum ScanDeviceAlert: Equatable {
    case remove(device: BluetoothDevice)

    var message: String {
        switch self {
        case .remove(let device):
            "Remove \(device.userFacingName) from favorites?"
        }
    }

    var title: String {
        switch self {
        case .remove(_):
            "Confirm"
        }
    }
}
