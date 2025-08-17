import SwiftUI

struct AddToFavoritesSheet: View {
    let device: BluetoothDevice

    let onSave: (BluetoothDevice, String) -> Void
    let onCancel: () -> Void

    @State private var nickname: String

    init(
        device: BluetoothDevice,
        onSave: @escaping (BluetoothDevice, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.device = device
        self.onSave = onSave
        self.onCancel = onCancel
        self._nickname = State(initialValue: device.nickname ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(device.name ?? "")) {
                    TextField("Nickname (optional)", text: $nickname)
                }
            }
            .navigationTitle("Add to favorites")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(device, nickname)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                }
            }
        }
    }
}

#Preview {
    AddToFavoritesSheet(
        device: BluetoothDevice(id: UUID(), name: "Name", rssi: -50),
        onSave: { _, _ in },
        onCancel: { }
    )
}
