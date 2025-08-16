import SwiftUI

@main
struct FavBlueApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppView(dependencies: dependencies)
        }
    }
}
