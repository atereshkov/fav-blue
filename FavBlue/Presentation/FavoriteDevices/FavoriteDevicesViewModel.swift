import Foundation

@MainActor
@Observable
final class FavoriteDevicesViewModel {

    private(set) var favoriteDevices: [Favorite] = []
    private(set) var state: FavoriteDevicesState = .loading

    private let useCase: FavoriteDevicesUseCaseType

    private var favoritesTask: Task<Void, Never>?

    init(useCase: FavoriteDevicesUseCaseType) {
        self.useCase = useCase
    }

    func start() async {
        state = .loading

        favoritesTask = Task { [weak self] in
            guard let self = self else { return }
            for await list in useCase.favoriteDevices() {
                self.favoriteDevices = list
//                    .map { FavoriteDeviceViewItem(name: $0.name ?? "") }
                self.state = .loaded
            }
        }

        // TODO: state = .error(error)
    }

    func stop() {
        favoritesTask?.cancel()
    }
}
