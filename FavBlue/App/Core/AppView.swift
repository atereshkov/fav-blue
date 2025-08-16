import SwiftUI

struct AppView: View {
    @State private var splashViewModel: SplashViewModel

    let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _splashViewModel = State(wrappedValue: dependencies.makeSplashViewModel())
    }

    var body: some View {
        ZStack {
            if splashViewModel.isFinished {
                favoritesView
            } else {
                splashView
            }
        }
        .animation(.easeInOut(duration: 0.45), value: splashViewModel.isFinished)
    }

    var favoritesView: some View {
        FavoriteDevicesView(
            viewModel: dependencies.makeFavoriteDevicesViewModel(),
            scanDevicesViewProvider: { scanDevicesView }
        )
        .opacity(splashViewModel.isFinished ? 1 : 0)
        .animation(.easeInOut(duration: 0.45), value: splashViewModel.isFinished)
    }

    var splashView: some View {
        SplashView()
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                removal: .opacity.combined(with: .move(edge: .top))
            ))
            .environment(splashViewModel)
    }

    var scanDevicesView: ScanDevicesView {
        ScanDevicesView(viewModel: dependencies.makeScanDevicesViewModel())
    }
}
