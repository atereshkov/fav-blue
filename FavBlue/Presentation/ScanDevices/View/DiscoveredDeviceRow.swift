import SwiftUI

struct DiscoveredDeviceRow: View {
    let item: BluetoothDevice
    let onTap: (BluetoothDevice) -> Void

    var body: some View {
        Button(action: {
            onTap(item)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.nickname ?? item.name ?? "Unknown")
                        .font(.headline)
                    Text(item.id.uuidString)
                        .font(.footnote)
                        .fontWeight(.regular)
                        .fontDesign(.monospaced)
                }
                Spacer()
                Text(String(item.rssi))
                Image(systemName: item.isFavorite ? "star.fill" : "star")
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRow(item: BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50)) { _ in }
}
