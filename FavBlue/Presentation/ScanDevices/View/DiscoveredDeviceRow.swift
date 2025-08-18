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
                    Text(item.userFacingName)
                        .font(.headline)
                        .fontWeight(item.isFavorite ? .semibold : .regular)
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
        .listRowBackground(
            item.isFavorite
                ? Color(.gray.withAlphaComponent(0.2))
                : Color(.systemBackground)
        )
    }
}

#Preview {
    DiscoveredDeviceRow(item: BluetoothDevice(id: UUID(), name: "Name 1", rssi: -50)) { _ in }
}
