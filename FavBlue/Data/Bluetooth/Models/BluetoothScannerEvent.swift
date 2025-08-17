import Foundation

enum BluetoothScannerEvent {
    case discovered(id: UUID, name: String?, rssi: Int)
    case stateChanged(BluetoothScannerState)
}
