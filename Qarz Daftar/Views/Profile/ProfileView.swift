import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore

    @State private var isEditProfilePresented = false
    @State private var isPinSetupPresented = false
    @State private var hasPinCode = PinCodeStore.hasPin()
    @State private var showNotificationDeniedAlert = false
    @State private var showBiometricUnavailableAlert = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileRowCard
                    settingsCard

                    Text("\(L10n.text(.version, language)): \(appVersion)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L10n.text(.profile, language))
            .sheet(isPresented: $isEditProfilePresented) {
                EditProfileView(profile: store.profile)
            }
            .sheet(isPresented: $isPinSetupPresented, onDismiss: {
                hasPinCode = PinCodeStore.hasPin()
            }) {
                PinSetupView(language: language) {
                    hasPinCode = true
                    if store.profile.appLockEnabled == false {
                        store.profile.appLockEnabled = true
                    }
                }
            }
            .alert(L10n.text(.notificationDeniedTitle, language), isPresented: $showNotificationDeniedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(L10n.text(.notificationDeniedMessage, language))
            }
            .alert(L10n.text(.biometricUnavailableTitle, language), isPresented: $showBiometricUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(L10n.text(.biometricUnavailableMessage, language))
            }
            .onAppear {
                hasPinCode = PinCodeStore.hasPin()
            }
        }
    }

    private var profileRowCard: some View {
        HStack(spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 5) {
                Text(store.profile.name.isEmpty ? L10n.text(.noName, language) : store.profile.name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)

                Text(profilePhoneText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                isEditProfilePresented = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 46, height: 46)
                    .background(Color.accentColor.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.text(.editProfile, language))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 10, y: 4)
    }

    private var avatarView: some View {
        Group {
            if let avatar = AvatarStorage.loadImage(path: store.profile.avatar) {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .foregroundStyle(Color.accentColor.opacity(0.85))
            }
        }
        .frame(width: 74, height: 74)
        .background(Color(.systemBackground), in: Circle())
        .overlay(
            Circle()
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        )
        .clipShape(Circle())
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                LanguageSelectionView()
            } label: {
                settingsNavigationRow(
                    systemImage: "globe",
                    tint: .blue,
                    title: L10n.text(.language, language),
                    value: store.profile.selectedLanguage.title
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 56)

            NavigationLink {
                ThemeSelectionView()
            } label: {
                settingsNavigationRow(
                    systemImage: "circle.lefthalf.filled",
                    tint: .indigo,
                    title: L10n.text(.theme, language),
                    value: themeTitle(store.profile.selectedTheme)
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 56)

            currencyRow

            Divider().padding(.leading, 56)

            Toggle(
                isOn: Binding(
                    get: { store.profile.notificationsEnabled },
                    set: { handleNotificationToggle($0) }
                )
            ) {
                HStack(spacing: 12) {
                    settingsIcon(systemImage: "bell.badge.fill", tint: .orange)
                    Text(L10n.text(.notifications, language))
                        .foregroundStyle(.primary)
                }
            }
            .tint(.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().padding(.leading, 56)

            Toggle(
                isOn: Binding(
                    get: { store.profile.appLockEnabled },
                    set: { handleAppLockToggle($0) }
                )
            ) {
                HStack(spacing: 12) {
                    settingsIcon(systemImage: "lock.fill", tint: .gray)
                    Text(L10n.text(.appLock, language))
                        .foregroundStyle(.primary)
                }
            }
            .tint(.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().padding(.leading, 56)

            Toggle(
                isOn: Binding(
                    get: { store.profile.biometricEnabled },
                    set: { handleBiometricToggle($0) }
                )
            ) {
                HStack(spacing: 12) {
                    settingsIcon(systemImage: "faceid", tint: .indigo)
                    Text(L10n.text(.useBiometric, language))
                        .foregroundStyle(.primary)
                }
            }
            .disabled(store.profile.appLockEnabled == false)
            .tint(.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().padding(.leading, 56)

            Button {
                isPinSetupPresented = true
            } label: {
                HStack(spacing: 12) {
                    settingsIcon(systemImage: "number.square.fill", tint: .blue)
                    Text(hasPinCode ? L10n.text(.changePin, language) : L10n.text(.setPin, language))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 5)
    }

    private func settingsNavigationRow(systemImage: String, tint: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            settingsIcon(systemImage: systemImage, tint: tint)

            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var currencyRow: some View {
        HStack(spacing: 12) {
            settingsIcon(systemImage: "dollarsign.circle.fill", tint: .green)

            Text(L10n.text(.currency, language))
                .foregroundStyle(.primary)

            Spacer()

            Menu {
                Picker(L10n.text(.currency, language), selection: $store.profile.selectedCurrency) {
                    ForEach(SupportedCurrency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(store.profile.selectedCurrency.rawValue)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func settingsIcon(systemImage: String, tint: Color) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 34, height: 34)
            .background(tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
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

    private func handleAppLockToggle(_ enabled: Bool) {
        if enabled == false {
            store.profile.appLockEnabled = false
            store.profile.biometricEnabled = false
            return
        }

        if hasPinCode {
            store.profile.appLockEnabled = true
            return
        }

        isPinSetupPresented = true
    }

    private func handleBiometricToggle(_ enabled: Bool) {
        if enabled == false {
            store.profile.biometricEnabled = false
            return
        }

        guard store.profile.appLockEnabled else {
            store.profile.biometricEnabled = false
            return
        }

        guard BiometricAuthService.canUseBiometrics() else {
            store.profile.biometricEnabled = false
            showBiometricUnavailableAlert = true
            return
        }

        store.profile.biometricEnabled = true
    }

    private var profilePhoneText: String {
        let phone = Formatters.formattedPhone(store.profile.phoneNumber)
        return phone.isEmpty ? L10n.text(.noPhone, language) : phone
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
