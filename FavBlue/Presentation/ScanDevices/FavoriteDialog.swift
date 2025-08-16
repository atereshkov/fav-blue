import Foundation

enum FavoriteDialog: Equatable {
    case add(device: BluetoothDevice)
    case remove(device: BluetoothDevice)
}
