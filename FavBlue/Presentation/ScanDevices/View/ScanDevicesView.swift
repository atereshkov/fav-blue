import SwiftUI

struct ScanDevicesView: View {

    let viewModel: ScanDevicesViewModel

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
        .sheet(isPresented: isShowingSheetBinding) {
            sheetView()
        }
        .alert(viewModel.activeDialog?.alertTitle ?? "", isPresented: isShowingDialogBinding) {
            alertView()
        } message: {
            Text(viewModel.activeDialog?.message ?? "")
        }
    }

    @ViewBuilder
    private func sheetView() -> some View {
        switch viewModel.activeSheet {
        case .addToFavorites(let device):
            AddToFavoritesSheet(
                device: device,
                onSave: { device, nickname in
                    viewModel.addFavorite(device, nickname: nickname)
                    viewModel.dismissSheet()
                },
                onCancel: {
                    viewModel.dismissSheet()
                }
            )
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func alertView() -> some View {
        switch viewModel.activeDialog {
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

    private var isShowingSheetBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.activeSheet != nil },
            set: { show in
                if !show { viewModel.dismissSheet() }
            }
        )
    }
}

#Preview {
    ScanDevicesView(
        viewModel: ScanDevicesViewModel(
            useCase: .previewMock(),
            favoritesUseCase: .previewMock()
        )
    )
}
