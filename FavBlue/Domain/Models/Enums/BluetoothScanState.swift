import Foundation

enum BluetoothScanState: Equatable {
    case idle
    case scanning // actually scanning
    case poweredOn // capable to operate
    case poweredOff
    case unsupported
    case unauthorized
    case resetting
    case unknown
    case error
}
