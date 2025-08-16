import Foundation

@MainActor
@Observable
final class FavoriteDevicesViewModel {

    private(set) var devices: [BluetoothDevice] = []
    private(set) var state: FavoriteDevicesState = .loading

    private let useCase: FavoriteDevicesUseCaseType

    init(useCase: FavoriteDevicesUseCaseType) {
        self.useCase = useCase
    }

    func start() async {
        do {
            state = .loading
            try await Task.sleep(for: .seconds(1))
            devices = try await useCase
                .fetchFavoriteDevices()
//                .map { FavoriteDeviceViewItem(name: $0.name ?? "") }
            state = .loaded
        } catch {
            state = .error(error)
        }
    }
}
