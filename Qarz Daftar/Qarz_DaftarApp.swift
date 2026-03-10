import SwiftUI

@main
struct Qarz_DaftarApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(store.profile.selectedTheme.colorScheme)
        }
    }
}
