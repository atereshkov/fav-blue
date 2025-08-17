import Foundation

enum ScanDeviceDialog: Equatable {
    case remove(device: BluetoothDevice)

    var message: String {
        switch self {
        case .remove(let device):
            "Remove \(device.nickname ?? device.name ?? "") from favorites?"
        }
    }

    var alertTitle: String {
        switch self {
        case .remove(_):
            "Confirm"
        }
    }
}
