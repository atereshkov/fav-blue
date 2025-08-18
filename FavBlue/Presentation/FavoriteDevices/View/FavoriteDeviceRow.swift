import SwiftUI

struct FavoriteDeviceRow: View {
    let item: Favorite
    let onTap: (Favorite) -> Void

    var body: some View {
        Button(action: {
            onTap(item)
        }) {
            VStack(alignment: .leading) {
                Text(item.userFacingName)
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
