import Foundation

@MainActor
@Observable
final class FavoriteDevicesViewModel {

    private let useCase: FavoriteDevicesUseCaseType

    private(set) var favoriteDevices: [Favorite] = []
    private(set) var state: FavoriteDevicesState = .loading

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
        // Edit nickname
    }

    func handleDeviceDelete(_ device: Favorite) {
        Task {
            await useCase.removeFavorite(deviceId: device.deviceId)
        }
    }
}
