import SwiftUI

struct SplashView: View {

    @Environment(SplashViewModel.self) private var viewModel: SplashViewModel

    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text(viewModel.name)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 42, weight: .bold))
                    .scaleEffect(animate ? 0.8 : 1.0)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(.easeOut(duration: AnimationDuration.medium), value: animate)
                Spacer()
            }
        }
        .onAppear {
            viewModel.start()
            withAnimation(.easeOut(duration: AnimationDuration.long)) { animate = true }
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}

#Preview {
    SplashView()
        .environment(SplashViewModel())
}
