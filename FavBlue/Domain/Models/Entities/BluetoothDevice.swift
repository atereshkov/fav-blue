import Foundation

struct BluetoothDevice: Identifiable, Hashable {
    let id: UUID
    var name: String?
    var rssi: Int

    var nickname: String?
    var isFavorite: Bool = false

    init(id: UUID, name: String?, rssi: Int) {
        self.id = id
        self.name = name
        self.rssi = rssi
    }

    mutating func update(name: String?, rssi: Int) {
        self.name = name
        self.rssi = rssi
    }
}
