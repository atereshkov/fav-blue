import SwiftUI

struct DiscoveredDeviceRow: View {
    let item: BluetoothDevice
    let onTap: (BluetoothDevice) -> Void

    var body: some View {
        Button(action: {
            onTap(item)
        }) {
            HStack {
                Text(item.name ?? "Unknown")
                Text(String(item.rssi))
                Spacer()
                Image(systemName: item.isFavorite ? "star.fill" : "star")
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRow(item: BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50)) { _ in }
}
