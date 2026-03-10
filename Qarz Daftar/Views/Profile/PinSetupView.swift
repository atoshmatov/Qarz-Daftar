import SwiftUI

struct PinSetupView: View {
    @Environment(\.dismiss) private var dismiss

    let language: AppLanguage
    let onSaved: () -> Void

    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField(L10n.text(.pinCode, language), text: $pin)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .onChange(of: pin) { newValue in
                            pin = normalize(newValue)
                        }

                    SecureField(L10n.text(.confirmPin, language), text: $confirmPin)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .onChange(of: confirmPin) { newValue in
                            confirmPin = normalize(newValue)
                        }
                } footer: {
                    Text(L10n.text(.pinHint, language))
                }
            }
            .navigationTitle(L10n.text(.setPin, language))
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text(.cancel, language)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text(.save, language)) {
                        savePin()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.text(.done, language)) {
                        Keyboard.dismiss()
                    }
                }
            }
            .alert(L10n.text(.details, language), isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func savePin() {
        guard pin.count == 4 else {
            alertMessage = L10n.text(.pinInvalidLength, language)
            isAlertPresented = true
            return
        }

        guard pin == confirmPin else {
            alertMessage = L10n.text(.pinMismatch, language)
            isAlertPresented = true
            return
        }

        guard PinCodeStore.save(pin: pin) else {
            alertMessage = L10n.text(.pinSaveFailed, language)
            isAlertPresented = true
            return
        }

        onSaved()
        dismiss()
    }

    private func normalize(_ value: String) -> String {
        String(value.filter { $0.isNumber }.prefix(4))
    }
}
