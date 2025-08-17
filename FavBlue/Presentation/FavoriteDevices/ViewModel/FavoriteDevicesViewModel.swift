import Foundation

@MainActor
@Observable
final class FavoriteDevicesViewModel {

    private let useCase: FavoriteDevicesUseCaseType

    private(set) var favoriteDevices: [Favorite] = []
    private(set) var state: FavoriteDevicesState = .loading
    private(set) var activeDialog: FavoriteDevicesDialog?
    private(set) var activeSheet: FavoriteDevicesSheet?

    private var favoritesTask: Task<Void, Never>?

    // MARK: - Lifecycle

    init(useCase: FavoriteDevicesUseCaseType) {
        self.useCase = useCase
    }

    deinit {
        print("FavoriteDevicesViewModel deinit")
    }

    // MARK: - Internal methods

    func start() {
        state = .loading

        favoritesTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = await useCase.favoriteDevices()
                for try await list in stream {
                    self.favoriteDevices = list
//                        .map { FavoriteDeviceViewItem(name: $0.name ?? "") }
                    self.state = list.isEmpty ? .empty : .loaded
                }
            } catch {
                if error is CancellationError { return }
                self.state = .error(error)
            }
        }
    }

    func stop() {
        favoritesTask?.cancel()
    }

    func handleDeviceTap(_ device: Favorite) {
        activeSheet = .changeNickname(device: device)
    }

    func deleteFavoriteRequested(_ device: Favorite) {
        activeDialog = .remove(device: device)
    }

    func deleteFavoriteConfirmed(_ device: Favorite) {
        Task {
            await useCase.removeFavorite(deviceId: device.deviceId)
        }
    }

    func changeNickname(device: Favorite, nickname: String?) {
        Task {
            await useCase.setNickname(deviceId: device.deviceId, nickname: nickname)
        }
    }

    func removeFavorite(device: Favorite) {
        Task {
            await useCase.removeFavorite(deviceId: device.deviceId)
        }
    }

    // MARK: - Private methods

    func dismissDialog() {
        activeDialog = nil
    }

    func dismissSheet() {
        activeSheet = nil
    }
}
