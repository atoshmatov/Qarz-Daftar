import LocalAuthentication
import SwiftUI

struct AppLockView: View {
    let language: AppLanguage
    let biometricEnabled: Bool
    let onUnlocked: () -> Void

    @State private var pinCode = ""
    @State private var errorMessage: String?
    @State private var isAuthenticatingBiometric = false

    private var canUseBiometric: Bool {
        biometricEnabled && BiometricAuthService.canUseBiometrics()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 0)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)

                Text(L10n.text(.unlockApp, language))
                    .font(.title3.weight(.semibold))

                SecureField(L10n.text(.enterPinToUnlock, language), text: $pinCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .onChange(of: pinCode) { newValue in
                        pinCode = normalize(newValue)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 6)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(L10n.text(.unlock, language)) {
                    verifyPin()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pinCode.count != 4)

                if canUseBiometric {
                    Button(biometricButtonTitle) {
                        authenticateWithBiometric()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isAuthenticatingBiometric)
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.text(.done, language)) {
                        Keyboard.dismiss()
                    }
                }
            }
        }
        .onAppear {
            guard canUseBiometric else { return }
            authenticateWithBiometric()
        }
    }

    private var biometricButtonTitle: String {
        switch BiometricAuthService.biometryType() {
        case .faceID:
            return L10n.text(.unlockWithFaceID, language)
        case .touchID:
            return L10n.text(.unlockWithTouchID, language)
        default:
            return L10n.text(.useBiometric, language)
        }
    }

    private func normalize(_ value: String) -> String {
        String(value.filter { $0.isNumber }.prefix(4))
    }

    private func verifyPin() {
        guard PinCodeStore.verify(pin: pinCode) else {
            errorMessage = L10n.text(.pinIncorrect, language)
            pinCode = ""
            return
        }

        errorMessage = nil
        onUnlocked()
    }

    private func authenticateWithBiometric() {
        guard canUseBiometric else { return }

        isAuthenticatingBiometric = true
        errorMessage = nil

        Task {
            let success = await BiometricAuthService.authenticate(reason: L10n.text(.biometricReason, language))
            await MainActor.run {
                isAuthenticatingBiometric = false
                if success {
                    onUnlocked()
                } else {
                    errorMessage = L10n.text(.biometricFailed, language)
                }
            }
        }
    }
}
