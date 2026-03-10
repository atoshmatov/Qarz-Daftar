import SwiftUI

struct EditDebtView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let debt: Debt
    let alreadyPaid: Double

    @State private var form: DebtFormData
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    init(debt: Debt, alreadyPaid: Double) {
        self.debt = debt
        self.alreadyPaid = alreadyPaid
        _form = State(initialValue: DebtFormData(from: debt))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.text(.personName, language), text: $form.personName)

                    Picker(L10n.text(.debtType, language), selection: $form.type) {
                        ForEach(DebtType.allCases) { type in
                            Text(type.title(language: language)).tag(type)
                        }
                    }

                    TextField(L10n.text(.amount, language), text: $form.totalAmountText)
                        .keyboardType(.numberPad)
                        .onChange(of: form.totalAmountText) { newValue in
                            let formattedValue = Formatters.formatAmountInput(newValue)
                            if formattedValue != newValue {
                                form.totalAmountText = formattedValue
                            }
                        }

                    Picker(L10n.text(.currency, language), selection: $form.currency) {
                        ForEach(SupportedCurrency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }

                    DatePicker(L10n.text(.date, language), selection: $form.createdAt, displayedComponents: .date)

                    Toggle(L10n.text(.dueDate, language), isOn: $form.hasDueDate.animation())
                    if form.hasDueDate {
                        DatePicker(L10n.text(.dueDate, language), selection: $form.dueDate, displayedComponents: .date)
                    }
                }

                Section {
                    TextField(L10n.text(.note, language), text: $form.note, axis: .vertical)
                        .lineLimit(2...4)
                    TextField(L10n.text(.phone, language), text: $form.phoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: form.phoneNumber) { newValue in
                            let formattedValue = Formatters.formatDebtPhoneInput(newValue)
                            if formattedValue != newValue {
                                form.phoneNumber = formattedValue
                            }
                        }
                    TextField(L10n.text(.category, language), text: $form.colorTag)
                }

                Section {
                    InfoRowView(
                        title: L10n.text(.paidAmount, language),
                        value: Formatters.currency(alreadyPaid, code: debt.currency)
                    )
                }
            }
            .navigationTitle(L10n.text(.editDebt, language))
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
            try store.updateDebt(
                id: debt.id,
                personName: form.personName,
                type: form.type,
                totalAmount: amount,
                currency: form.currency,
                note: form.note,
                createdAt: form.createdAt,
                dueDate: form.dueDateValue(),
                phoneNumber: Formatters.debtPhoneStorageDigits(form.phoneNumber),
                colorTag: form.colorTag
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
