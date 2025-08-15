import SwiftUI

struct FavoriteDeviceRow: View {
    let item: Device

    var body: some View {
        Button(action: {
//            showingAlert = true
        }) {
            Text(item.name)
        }
    }
}

#Preview {
    FavoriteDeviceRow(item: Device(id: "1", name: "Device 1", nickname: "Nickname 1"))
}
