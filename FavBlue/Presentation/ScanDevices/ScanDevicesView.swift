import SwiftUI

struct ScanDevicesView: View {

    let viewModel: ScanDevicesViewModel

    @State private var nickname: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            switch viewModel.state {
            case .idle(let message):
                idleView(message)
            case .scanning:
                discoveredDevicesList
            case .error(let error):
                errorView(error)
            }
        }
        .navigationTitle("Scan Devices")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.state == .scanning {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .alert(alertTitle(), isPresented: isShowingDialogBinding) {
            switch viewModel.activeDialog {
            case .add(let device):
                // TODO: TextField issue - replace with a screen? (TextField + Save in toolbar)
                TextField("Nickname", text: $nickname)
                Button("Add") {
                    viewModel.addFavorite(device, nickname: nickname)
                }
                Button("Cancel", role: .cancel) {
                    viewModel.dismissDialog()
                }
            case .remove(let device):
                Button("Remove", role: .destructive) {
                    viewModel.removeFavorite(device: device)
                }
                Button("Cancel", role: .cancel) {
                    viewModel.dismissDialog()
                }
            case .none:
                EmptyView()
            }
        } message: {
            switch viewModel.activeDialog {
            case .add(_):
                Text("Enter device nickname (optional)")
            case .remove(let device):
                // TODO nickname first
                Text("Remove \(device.name ?? "") from favorites?")
            case .none:
                EmptyView()
            }
        }
    }

    private var scanStatus: some View {
        HStack {
            Text("Scanning...")
            ProgressView()
        }
        .padding([.leading, .trailing], 24)
    }

    private var discoveredDevicesList: some View {
        List {
            Section("Discovered Devices") {
                ForEach(viewModel.devices) { item in
                    DiscoveredDeviceRow(item: item) { item in
                        viewModel.handleDeviceTap(item)
                    }
                }
            }
        }
    }

    private func errorView(_ error: ScanDevicesStateError) -> some View {
        VStack {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(.large)
            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
            Button("Retry") {
                Task {
                    viewModel.start()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func idleView(_ message: String?) -> some View {
        VStack {
            Text(message ?? "Unknown status")
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var isShowingDialogBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.activeDialog != nil },
            set: { show in
                if !show { viewModel.dismissDialog() }
            }
        )
    }

    private func alertTitle() -> String {
        switch viewModel.activeDialog {
        case .add: return "Add to favorites"
        case .remove: return "Remove from favorites?"
        case .none: return ""
        }
    }
}

#Preview {
//    ScanDevicesView(
//        viewModel: ScanDevicesViewModel(
//            useCase: BluetoothScannerUseCase(
//                repository: BluetoothScannerRepository(bluetoothScanner: BluetoothScanner()),
//                favoritesRepository: FavoriteDevicesRepository()
//            ),
//            favoritesUseCase: FavoritesManagementUseCase(repository: FavoriteDevicesRepository())
//        )
//    )
}
