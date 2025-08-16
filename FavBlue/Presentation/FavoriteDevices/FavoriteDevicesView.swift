import SwiftUI

struct FavoriteDevicesView<ScanDevicesView: View>: View {

    let viewModel: FavoriteDevicesViewModel
    let scanDevicesViewProvider: () -> ScanDevicesView

    @State private var showingAlert = false
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .loading:
                    loadingIndicator
                case .loaded:
                    devicesList
                    bottomFooter
                case .error(let error):
                    errorView(error)
                }
            }
            .onAppear {
                viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
            .alert("Alert Title", isPresented: $showingAlert) {
                TextField(text: $name) {}
                Button("Submit") {
                    print("Submit")
                }
                Button("Cancel") {
                    print("Skip")
                }
            } message: {
                Text("Enter device nickname (optional)")
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var devicesList: some View {
        List {
            ForEach(viewModel.favoriteDevices) { item in
                FavoriteDeviceRow(item: item)
                .swipeActions {
                    Button() {
                        print("Delete")
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(.red)
                }
            }
        }
    }

    private var emptyState: some View {
        Text("No favorite devices yet.")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func errorView(_ error: Error?) -> some View {
        VStack {
            Text("An error occurred while loading devices.")
                .foregroundColor(.red)
                .padding()
            Button("Retry") {
                Task {
                    await viewModel.start()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bottomFooter: some View {
        NavigationLink(destination: LazyNavigationView(scanDevicesViewProvider())) {
            Text("Add New Devices")
                .background(Color.blue)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
    }
}

#Preview {
    FavoriteDevicesView(
        viewModel: FavoriteDevicesViewModel(useCase: MockFavoriteDevicesUseCase()),
        scanDevicesViewProvider: { EmptyView() }
    )
}

final class MockFavoriteDevicesUseCase: FavoriteDevicesUseCaseType {
    func favoriteDevices() -> AsyncStream<[Favorite]> {
        AsyncStream { continuation in
            let items = [
                Favorite(deviceId: UUID(), lastKnownName: "Known1", nickname: "Name 1"),
                Favorite(deviceId: UUID(), lastKnownName: "Known 2", nickname: nil),
            ]
            continuation.yield(items)
        }
    }
}
