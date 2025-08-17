import Foundation
import CoreBluetooth

enum BluetoothScannerState: Equatable {
    case scanning
    case poweredOn
    case poweredOff
    case unsupported
    case unauthorized
    case resetting
    case unknown
}

extension BluetoothScannerState {
    static func from(_ cbState: CBManagerState) -> BluetoothScannerState {
        switch cbState {
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .unauthorized: return .unauthorized
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        @unknown default:
            return .unknown
        }
    }
}
