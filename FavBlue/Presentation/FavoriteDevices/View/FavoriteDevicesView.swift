import SwiftUI

struct FavoriteDevicesView<ScanDevicesView: View>: View {

    let viewModel: FavoriteDevicesViewModel
    let scanDevicesViewProvider: () -> ScanDevicesView

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
            .sheet(isPresented: isShowingSheetBinding) {
                sheetView()
            }
            .alert(viewModel.activeDialog?.alertTitle ?? "", isPresented: isShowingDialogBinding) {
                alertView()
            } message: {
                Text(viewModel.activeDialog?.message ?? "")
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func sheetView() -> some View {
        switch viewModel.activeSheet {
        case .changeNickname(let favorite):
            DeviceNicknameSheet(
                favorite: favorite,
                onSave: { favorite, nickname in
                    viewModel.changeNickname(device: favorite, nickname: nickname)
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
                viewModel.deleteFavoriteConfirmed(device)
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissDialog()
            }
        case .none:
            EmptyView()
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
                        viewModel.deleteFavoriteRequested(item)
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
            Text("Why don't you add your first one?")
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
    FavoriteDevicesView(
        viewModel: FavoriteDevicesViewModel(useCase: .previewMock()),
        scanDevicesViewProvider: { EmptyView() }
    )
}
