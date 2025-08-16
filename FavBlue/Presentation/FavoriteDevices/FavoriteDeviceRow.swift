import SwiftUI

struct FavoriteDeviceRow: View {
    // TODO: use RowViewModel
    let item: Favorite

    var body: some View {
        Button(action: {
//            showingAlert = true
        }) {
            Text(item.nickname ?? item.lastKnownName ?? "")
        }
    }
}

#Preview {
    FavoriteDeviceRow(item: Favorite(deviceId: UUID(), lastKnownName: "Known", nickname: "Nickname"))
}
