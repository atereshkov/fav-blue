import Foundation

enum ScanDevicesState: Equatable {
    case idle(message: String?)
    case scanning
    case error(ScanDevicesStateError)
}

enum ScanDevicesStateError: Error {
    case unsupported
    case unauthorized
    case resetting
    case unknown

    var message: String {
        switch self {
        case .unsupported:
            "The Bluetooth is not supported on this platform."
        case .unauthorized:
            "The app is not authorized to use Bluetooth. Please check permissions and try again."
        case .resetting:
            "Connection lost. Please try again."
        case .unknown:
            "Unknown error. Please try again."
        }
    }
}
