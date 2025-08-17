import Foundation

enum DeviceSortOption {
    case byNameThenRssi
    case byRssiOnly
    case custom((BluetoothDevice, BluetoothDevice) -> Bool)
}
