import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("didAskNotificationPermission") private var didAskNotificationPermission = false

    @State private var showSplash = true
    @State private var showNotificationPrompt = false
    @State private var showAppLock = false
    @State private var shouldLockOnActive = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        Group {
            if showSplash {
                SplashView(language: language)
                    .transition(.opacity)
            } else {
                TabView {
                    MainView()
                        .tabItem {
                            Label(L10n.text(.mainTab, language), systemImage: "house.fill")
                        }

                    StatisticsView()
                        .tabItem {
                            Label(L10n.text(.statistics, language), systemImage: "chart.bar.xaxis")
                        }

                    ProfileView()
                        .tabItem {
                            Label(L10n.text(.profileTab, language), systemImage: "person.crop.circle")
                        }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSplash)
        .task {
            guard showSplash else { return }
            try? await Task.sleep(for: .seconds(1.0))
            showSplash = false
            await checkNotificationPermission()
            refreshLockStateIfNeeded()
        }
        .onChange(of: scenePhase) { phase in
            guard showSplash == false else { return }
            switch phase {
            case .background:
                shouldLockOnActive = true
            case .active:
                if shouldLockOnActive {
                    shouldLockOnActive = false
                    refreshLockStateIfNeeded()
                }
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onChange(of: store.profile.appLockEnabled) { enabled in
            if enabled == false {
                showAppLock = false
            } else {
                refreshLockStateIfNeeded()
            }
        }
        .alert(L10n.text(.notificationPromptTitle, language), isPresented: $showNotificationPrompt) {
            Button(L10n.text(.enableNotifications, language)) {
                requestNotificationPermission()
            }
            Button(L10n.text(.notNow, language), role: .cancel) {
                didAskNotificationPermission = true
            }
        } message: {
            Text(L10n.text(.notificationPromptMessage, language))
        }
        .fullScreenCover(isPresented: $showAppLock) {
            AppLockView(
                language: language,
                biometricEnabled: store.profile.biometricEnabled
            ) {
                showAppLock = false
            }
            .interactiveDismissDisabled(true)
        }
    }

    private func requestNotificationPermission() {
        didAskNotificationPermission = true
        Task {
            let granted = await NotificationService.requestAuthorization()
            await MainActor.run {
                store.profile.notificationsEnabled = granted
            }
        }
    }

    private func checkNotificationPermission() async {
        let status = await NotificationService.authorizationStatus()

        await MainActor.run {
            switch status {
            case .authorized, .provisional, .ephemeral:
                break
            case .denied:
                store.profile.notificationsEnabled = false
            case .notDetermined:
                if didAskNotificationPermission == false {
                    showNotificationPrompt = true
                }
            @unknown default:
                break
            }
        }
    }

    private func refreshLockStateIfNeeded() {
        guard store.profile.appLockEnabled else {
            showAppLock = false
            return
        }
        guard PinCodeStore.hasPin() else {
            showAppLock = false
            return
        }
        showAppLock = true
    }
}
