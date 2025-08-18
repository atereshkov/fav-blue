import Foundation

@MainActor
@Observable
final class SplashViewModel {

    // MARK: - Internal properties

    private(set) var name: String = "Aliaksandr Tserashkou"
    private(set) var isFinished: Bool = false

    // MARK: - Private properties

    private var timerTask: Task<Void, Never>?

    // MARK: - Internal

    func start(timeoutSeconds: TimeInterval = 2) {
        guard timerTask == nil else { return }

        timerTask = Task {
            try? await Task.sleep(for: .seconds(timeoutSeconds))
            if Task.isCancelled { return }
            isFinished = true
        }
    }

    func cancel() {
        timerTask?.cancel()
        timerTask = nil
    }
}
