import SwiftUI

struct FavoriteDeviceRow: View {
    // TODO: use RowViewModel
    let item: Favorite
    let onTap: (Favorite) -> Void

    var body: some View {
        Button(action: {
            onTap(item)
        }) {
            VStack(alignment: .leading) {
                Text(item.nickname ?? item.lastKnownName ?? "Unknown")
                    .font(.headline)
                Text(item.deviceId.uuidString)
                    .font(.footnote)
                    .fontWeight(.regular)
                    .fontDesign(.monospaced)
            }
        }
    }
}

#Preview {
    FavoriteDeviceRow(item: Favorite(deviceId: UUID(), lastKnownName: "Known", nickname: "Nickname")) { _ in }
}
