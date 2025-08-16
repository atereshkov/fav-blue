import SwiftUI

struct ScanDevicesView: View {

    let viewModel: ScanDevicesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            switch viewModel.state {
            case .idle:
                idleView
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
                        viewModel.handleDeviceTap(device: item)
                    }
                }
            }
        }
    }

    private func errorView(_ error: Error?) -> some View {
        VStack {
            Text("An error occurred: \(error).")
                .foregroundColor(.red)
                .padding()
            Button("Retry") {
                Task {
                    viewModel.start()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var idleView: some View {
        VStack {
            Text("Warming up...")
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
