import SwiftUI

struct DebtDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let debtID: UUID

    @State private var isEditPresented = false
    @State private var isAddPaymentPresented = false
    @State private var isAddToDebtPresented = false
    @State private var isDeleteConfirmPresented = false
    @State private var alertMessage: String?
    @State private var isErrorAlertPresented = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    private var debt: Debt? {
        store.debt(by: debtID)
    }

    private var paidAmount: Double {
        store.paidAmount(for: debtID)
    }

    private var debtPayments: [Payment] {
        store.payments(for: debtID)
    }

    var body: some View {
        Group {
            if let debt {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        DebtRowCardView(
                            debt: debt,
                            paidAmount: paidAmount,
                            remainingAmount: store.remainingAmount(for: debt),
                            isClosed: store.isClosed(debt),
                            language: language
                        )

                        detailsSection(debt)
                        paymentsSection(debt)
                        actionsSection(debt)
                    }
                    .padding()
                }
            } else {
                EmptyStateView(
                    title: L10n.text(.details, language),
                    subtitle: L10n.text(.emptyListSubtitle, language)
                )
                .padding()
            }
        }
        .navigationTitle(L10n.text(.details, language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if debt != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(L10n.text(.editDebt, language)) {
                            isEditPresented = true
                        }

                        Button(L10n.text(.delete, language), role: .destructive) {
                            isDeleteConfirmPresented = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isEditPresented) {
            if let debt {
                EditDebtView(debt: debt, alreadyPaid: paidAmount)
            }
        }
        .sheet(isPresented: $isAddPaymentPresented) {
            if let debt {
                AddPaymentView(debt: debt, remaining: store.remainingAmount(for: debt))
            }
        }
        .sheet(isPresented: $isAddToDebtPresented) {
            if let debt {
                AddToDebtView(debt: debt)
            }
        }
        .alert(L10n.text(.deleteConfirmation, language), isPresented: $isDeleteConfirmPresented, actions: {
            Button(L10n.text(.delete, language), role: .destructive) {
                if let debt {
                    store.deleteDebt(id: debt.id)
                }
                dismiss()
            }
            Button(L10n.text(.cancel, language), role: .cancel) { }
        }, message: {
            Text(L10n.text(.deleteMessage, language))
        })
        .alert(L10n.text(.details, language), isPresented: $isErrorAlertPresented, actions: {
            Button("OK", role: .cancel) {
                alertMessage = nil
            }
        }, message: {
            Text(alertMessage ?? "")
        })
    }

    @ViewBuilder
    private func detailsSection(_ debt: Debt) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.text(.details, language))
                .font(.headline)

            InfoRowView(
                title: L10n.text(.debtType, language),
                value: debt.type.title(language: language)
            )
            InfoRowView(
                title: L10n.text(.totalAmount, language),
                value: Formatters.currency(debt.totalAmount, code: debt.currency)
            )
            InfoRowView(
                title: L10n.text(.paidAmount, language),
                value: Formatters.currency(paidAmount, code: debt.currency)
            )
            InfoRowView(
                title: L10n.text(.remainingAmount, language),
                value: Formatters.currency(store.remainingAmount(for: debt), code: debt.currency)
            )
            InfoRowView(
                title: L10n.text(.createdAt, language),
                value: Formatters.dateFormatter.string(from: debt.createdAt)
            )
            InfoRowView(
                title: L10n.text(.dueDate, language),
                value: debt.dueDate.map { Formatters.dateFormatter.string(from: $0) } ?? L10n.text(.noDueDate, language)
            )

            if debt.note.isEmpty == false {
                InfoRowView(title: L10n.text(.note, language), value: debt.note)
            }
            if debt.phoneNumber.isEmpty == false {
                InfoRowView(title: L10n.text(.phone, language), value: Formatters.formattedPhone(debt.phoneNumber))
            }
            if debt.colorTag.isEmpty == false {
                InfoRowView(title: L10n.text(.category, language), value: debt.colorTag)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func paymentsSection(_ debt: Debt) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L10n.text(.paymentHistory, language))
                    .font(.headline)
                Spacer()
                Button(L10n.text(.addPayment, language)) {
                    isAddPaymentPresented = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isClosed(debt))
            }

            if debtPayments.isEmpty {
                Text(L10n.text(.noPayments, language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(debtPayments) { payment in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Formatters.currency(payment.amount, code: debt.currency))
                                .fontWeight(.semibold)
                            if payment.note.isEmpty == false {
                                Text(payment.note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(Formatters.dateFormatter.string(from: payment.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func actionsSection(_ debt: Debt) -> some View {
        VStack(spacing: 10) {
            Button(L10n.text(.addToDebt, language)) {
                isAddToDebtPresented = true
            }
            .buttonStyle(.borderedProminent)

            Button(L10n.text(.closeDebt, language)) {
                do {
                    try store.markDebtClosed(id: debt.id)
                } catch let error as ValidationError {
                    alertMessage = L10n.validationMessage(error, language)
                    isErrorAlertPresented = true
                } catch {
                    alertMessage = L10n.text(.details, language)
                    isErrorAlertPresented = true
                }
            }
            .buttonStyle(.bordered)
            .disabled(store.isClosed(debt))

            Button(L10n.text(.editDebt, language)) {
                isEditPresented = true
            }
            .buttonStyle(.bordered)

            Button(L10n.text(.delete, language), role: .destructive) {
                isDeleteConfirmPresented = true
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AddToDebtView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let debt: Debt

    @State private var amountText: String = ""
    @State private var alertMessage: String?
    @State private var isAlertPresented = false

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    InfoRowView(
                        title: L10n.text(.totalAmount, language),
                        value: Formatters.currency(debt.totalAmount, code: debt.currency)
                    )
                    TextField(L10n.text(.amount, language), text: $amountText)
                        .keyboardType(.numberPad)
                        .onChange(of: amountText) { newValue in
                            let formattedValue = Formatters.formatAmountInput(newValue)
                            if formattedValue != newValue {
                                amountText = formattedValue
                            }
                        }
                }
            }
            .navigationTitle(L10n.text(.addToDebt, language))
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
            .alert(L10n.text(.details, language), isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func save() {
        guard let amount = Formatters.amountValue(fromInput: amountText), amount > 0 else {
            alertMessage = L10n.text(.validationAmount, language)
            isAlertPresented = true
            return
        }

        do {
            try store.addToDebt(id: debt.id, amount: amount)
            dismiss()
        } catch let error as ValidationError {
            alertMessage = L10n.validationMessage(error, language)
            isAlertPresented = true
        } catch {
            alertMessage = L10n.text(.details, language)
            isAlertPresented = true
        }
    }
}
