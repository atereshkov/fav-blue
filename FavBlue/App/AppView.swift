import SwiftUI

struct AppView: View {
    @State private var splashViewModel = SplashViewModel()

    var body: some View {
        ZStack {
            if splashViewModel.isFinished {
                makeFavoriteDevicesView()
                    .opacity(splashViewModel.isFinished ? 1 : 0)
                    .animation(.easeInOut(duration: 0.45), value: splashViewModel.isFinished)
            } else {
                SplashView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .environment(splashViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: splashViewModel.isFinished)
    }

    private func makeFavoriteDevicesView() -> FavoriteDevicesView {
        let repository = FavoriteDevicesRepository()
        let useCase = FavoriteDevicesUseCase(repository: repository)
        let viewModel = FavoriteDevicesViewModel(useCase: useCase)
        return FavoriteDevicesView(viewModel: viewModel)
    }
}
