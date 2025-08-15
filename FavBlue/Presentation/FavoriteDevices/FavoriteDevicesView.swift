import SwiftUI

struct FavoriteDevicesView: View {

    @State private var showingAlert = false

    @State private var name: String = ""

    let viewModel: FavoriteDevicesViewModel

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
                    errorView(error: error)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.start()
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
            Text("Enter channel name")
        }
    }

    private var devicesList: some View {
        List {
            ForEach(viewModel.devices) { item in
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

    private func errorView(error: Error?) -> some View {
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
        NavigationLink(destination: EmptyView()) {
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
    FavoriteDevicesView(viewModel: FavoriteDevicesViewModel(useCase: MockFavoriteDevicesUseCase()))
}

final class MockFavoriteDevicesUseCase: FavoriteDevicesUseCaseType {
    func fetchFavoriteDevices() async throws -> [Device] {
        return [
            Device(id: "1", name: "Device 1", nickname: nil),
            Device(id: "2", name: "Device 2", nickname: "Nickname 2"),
        ]
    }
}
