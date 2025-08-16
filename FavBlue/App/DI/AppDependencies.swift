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
            useCase: BluetoothScannerUseCase(
                repository: BluetoothScannerRepository(bluetoothScanner: BluetoothScanner()),
                favoritesRepository: favoriteRepository
            ),
            favoritesUseCase: makeFavoritesManagementUseCase()
        )
    }

    // MARK: - Use Cases

    private func makeFavoriteDevicesUseCase() -> FavoriteDevicesUseCase {
        FavoriteDevicesUseCase(repository: favoriteRepository)
    }

    private func makeFavoritesManagementUseCase() -> FavoritesManagementUseCase {
        FavoritesManagementUseCase(repository: favoriteRepository)
    }
}
