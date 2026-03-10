import SwiftUI

struct AddPaymentView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let debt: Debt
    let remaining: Double

    @State private var form = PaymentFormData()
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    InfoRowView(
                        title: L10n.text(.remainingAmount, language),
                        value: Formatters.currency(remaining, code: debt.currency)
                    )
                }

                Section {
                    TextField(L10n.text(.amount, language), text: $form.amountText)
                        .keyboardType(.numberPad)
                        .onChange(of: form.amountText) { newValue in
                            let formattedValue = Formatters.formatAmountInput(newValue)
                            if formattedValue != newValue {
                                form.amountText = formattedValue
                            }
                        }
                    DatePicker(L10n.text(.date, language), selection: $form.date, displayedComponents: .date)
                    TextField(L10n.text(.note, language), text: $form.note, axis: .vertical)
                        .lineLimit(2...3)
                }
            }
            .navigationTitle(L10n.text(.addPayment, language))
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text(.cancel, language)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text(.save, language)) {
                        save()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.text(.done, language)) {
                        Keyboard.dismiss()
                    }
                }
            }
            .alert(L10n.text(.details, language), isPresented: $isAlertPresented, actions: {
                Button("OK", role: .cancel) {
                    alertMessage = nil
                }
            }, message: {
                Text(alertMessage ?? "")
            })
        }
    }

    private func save() {
        guard let amount = form.amountValue() else {
            alertMessage = L10n.text(.validationAmount, language)
            isAlertPresented = true
            return
        }

        do {
            try store.addPayment(
                debtId: debt.id,
                amount: amount,
                date: form.date,
                note: form.note
            )
            dismiss()
        } catch let error as ValidationError {
            alertMessage = L10n.validationMessage(error, language)
            isAlertPresented = true
        } catch {
            alertMessage = L10n.text(.validationAmount, language)
            isAlertPresented = true
        }
    }
}
