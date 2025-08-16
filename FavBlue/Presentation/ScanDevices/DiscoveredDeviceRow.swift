import SwiftUI

struct DiscoveredDeviceRow: View {
    let item: BluetoothDevice

    var body: some View {
        Button(action: {
            //
        }) {
            HStack {
                Text(item.name ?? "Unknown")
                Text(String(item.rssi))
                Spacer()
                Image(systemName: "star")
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRow(item: BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50))
}
