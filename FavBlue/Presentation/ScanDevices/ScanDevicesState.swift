import Foundation

enum ScanDevicesState: Equatable {
    case idle
    case scanning
    case error(Error?)

    static func == (lhs: ScanDevicesState, rhs: ScanDevicesState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
          return true
        case (.scanning, .scanning):
          return true
        case (.error(let lhsError), .error(let rhsError)):
            // TODO: fix
            return true
        default:
          return false
        }
    }
}
