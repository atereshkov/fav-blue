import Foundation

@Observable
final class AppDependencies {
    let favoriteRepository: FavoriteDevicesRepository

    init() {
        favoriteRepository = FavoriteDevicesRepository()
    }

    // MARK: - Internal Methods - View Models

    @MainActor func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel()
    }

    @MainActor func makeFavoriteDevicesViewModel() -> FavoriteDevicesViewModel {
        FavoriteDevicesViewModel(useCase: makeFavoriteDevicesUseCase())
    }

    @MainActor func makeScanDevicesViewModel() -> ScanDevicesViewModel {
        ScanDevicesViewModel(
            useCase: makeBluetoothScannerUseCase(),
            favoritesUseCase: makeFavoriteDevicesUseCase()
        )
    }

    // MARK: - Use Cases

    private func makeFavoriteDevicesUseCase() -> FavoriteDevicesUseCase {
        FavoriteDevicesUseCase(repository: favoriteRepository)
    }

    private func makeBluetoothScannerUseCase() -> BluetoothScannerUseCase {
        BluetoothScannerUseCase(
            repository: BluetoothScannerRepository(bluetoothScanner: BluetoothScanner()),
            favoritesRepository: favoriteRepository
        )
    }
}
