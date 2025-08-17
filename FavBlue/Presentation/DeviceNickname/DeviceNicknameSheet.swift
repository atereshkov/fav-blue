import SwiftUI

struct DeviceNicknameSheet: View {
    let favorite: Favorite

    let onSave: (Favorite, String?) -> Void
    let onCancel: () -> Void

    @State private var nickname: String

    init(
        favorite: Favorite,
        onSave: @escaping (Favorite, String?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.favorite = favorite
        self.onSave = onSave
        self.onCancel = onCancel
        self._nickname = State(initialValue: favorite.nickname ?? favorite.lastKnownName ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nickname", text: $nickname)
                    Text("Editing nickname for this favorite.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit nickname")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(favorite, nickname)
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
    DeviceNicknameSheet(
        favorite: Favorite(deviceId: UUID(), lastKnownName: "Last name", nickname: "Nick"),
        onSave: { _, _ in },
        onCancel: { }
    )
}
