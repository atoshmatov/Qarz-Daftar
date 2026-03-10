import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var showNotificationDeniedAlert = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        Form {
            Section {
                NavigationLink(L10n.text(.language, language)) {
                    LanguageSelectionView()
                }

                NavigationLink(L10n.text(.theme, language)) {
                    ThemeSelectionView()
                }

                Picker(L10n.text(.currency, language), selection: $store.profile.selectedCurrency) {
                    ForEach(SupportedCurrency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            }

            Section {
                Toggle(
                    L10n.text(.notifications, language),
                    isOn: Binding(
                        get: { store.profile.notificationsEnabled },
                        set: { handleNotificationToggle($0) }
                    )
                )
                HStack {
                    Text(L10n.text(.backupRestore, language))
                    Spacer()
                    Text("Soon")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(L10n.text(.settings, language))
        .alert(L10n.text(.notificationDeniedTitle, language), isPresented: $showNotificationDeniedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L10n.text(.notificationDeniedMessage, language))
        }
    }

    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled == false {
            store.profile.notificationsEnabled = false
            Task {
                await NotificationService.removeAllDebtReminders()
            }
            return
        }

        Task {
            let status = await NotificationService.authorizationStatus()

            if status == .denied {
                await MainActor.run {
                    store.profile.notificationsEnabled = false
                    showNotificationDeniedAlert = true
                }
                return
            }

            let granted: Bool
            if status == .authorized || status == .provisional || status == .ephemeral {
                granted = true
            } else {
                granted = await NotificationService.requestAuthorization()
            }

            await MainActor.run {
                store.profile.notificationsEnabled = granted
                if granted == false {
                    showNotificationDeniedAlert = true
                }
            }
        }
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject private var store: AppStore

    private var language: AppLanguage { store.profile.selectedLanguage }
    private var languageItems: [(offset: Int, element: AppLanguage)] {
        Array(AppLanguage.allCases.enumerated())
    }

    var body: some View {
        List {
            ForEach(languageItems, id: \.offset) { _, item in
                Button {
                    store.profile.selectedLanguage = item
                } label: {
                    HStack {
                        Text(item.title)
                            .foregroundStyle(.primary)
                        Spacer()
                        if store.profile.selectedLanguage == item {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.text(.language, language))
    }
}

struct ThemeSelectionView: View {
    @EnvironmentObject private var store: AppStore

    private var language: AppLanguage { store.profile.selectedLanguage }
    private var themeItems: [(offset: Int, element: AppTheme)] {
        Array(AppTheme.allCases.enumerated())
    }

    var body: some View {
        List {
            ForEach(themeItems, id: \.offset) { _, item in
                Button {
                    store.profile.selectedTheme = item
                } label: {
                    HStack {
                        Text(themeTitle(item))
                            .foregroundStyle(.primary)
                        Spacer()
                        if store.profile.selectedTheme == item {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.text(.theme, language))
    }

    private func themeTitle(_ theme: AppTheme) -> String {
        switch theme {
        case .system:
            return L10n.text(.system, language)
        case .light:
            return L10n.text(.light, language)
        case .dark:
            return L10n.text(.dark, language)
        }
    }
}
