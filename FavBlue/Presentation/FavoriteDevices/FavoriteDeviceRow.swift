import SwiftUI

struct FavoriteDeviceRow: View {
    let item: BluetoothDevice

    var body: some View {
        Button(action: {
//            showingAlert = true
        }) {
            Text(item.name ?? "")
        }
    }
}

#Preview {
    FavoriteDeviceRow(item: BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50))
}
