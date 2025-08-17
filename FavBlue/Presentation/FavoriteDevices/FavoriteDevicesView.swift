import SwiftUI

struct FavoriteDevicesView<ScanDevicesView: View>: View {

    let viewModel: FavoriteDevicesViewModel
    let scanDevicesViewProvider: () -> ScanDevicesView

    @State private var showingAlert = false
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch viewModel.state {
                case .loading:
                    loadingIndicator
                case .empty:
                    emptyState
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
                FavoriteDeviceRow(item: item) { item in
                    viewModel.handleDeviceTap(item)
                }
                .swipeActions {
                    Button() {
                        viewModel.handleDeviceDelete(item)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(.red)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No favorite devices yet", systemImage: "star")
        } description: {
            Text("Why don't you add some?")
        } actions: {
            NavigationLink(destination: LazyNavigationView(scanDevicesViewProvider())) {
                Text("Add New Devices")
            }
            .buttonStyle(.borderedProminent)
        }
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
                viewModel.start()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bottomFooter: some View {
        VStack {
            NavigationLink(destination: LazyNavigationView(scanDevicesViewProvider())) {
                Text("Add New Devices")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .controlSize(.large)
        }
        .padding()
        .background(
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        )
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

    func addFavorite(deviceId: UUID, lastKnownName: String?, nickname: String?) async {

    }

    func removeFavorite(deviceId: UUID) async {

    }

    func setNickname(deviceId: UUID, nickname: String?) async {
        
    }
}
