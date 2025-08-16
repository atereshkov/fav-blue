import Foundation

struct BluetoothDevice: Identifiable, Hashable {
    let id: UUID
    var name: String?
    var rssi: Int

    var nickname: String?
    var isFavorite: Bool = false

    init(id: UUID, name: String?, rssi: NSNumber) {
        self.id = id
        self.name = name
        self.rssi = rssi.intValue
    }

    mutating func update(name: String?, rssi: NSNumber) {
        self.name = name
        self.rssi = rssi.intValue
    }
}

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
