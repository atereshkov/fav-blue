import Foundation

extension BluetoothScannerState {
    func toDomain() -> BluetoothScanState {
        switch self {
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .unauthorized: return .unauthorized
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        case .scanning: return .scanning
        @unknown default:
            return .unknown
        }
    }
}
