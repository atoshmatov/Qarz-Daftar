import Foundation

struct DebtFormData {
    var personName: String = ""
    var type: DebtType = .borrowed
    var totalAmountText: String = ""
    var currency: SupportedCurrency = .uzs
    var note: String = ""
    var createdAt: Date = .now
    var hasDueDate: Bool = false
    var dueDate: Date = .now
    var phoneNumber: String = ""
    var colorTag: String = ""

    init() {}

    init(from debt: Debt) {
        personName = debt.personName
        type = debt.type
        totalAmountText = Self.toAmountString(debt.totalAmount)
        currency = SupportedCurrency(rawValue: debt.currency) ?? .uzs
        note = debt.note
        createdAt = debt.createdAt
        if let due = debt.dueDate {
            hasDueDate = true
            dueDate = due
        } else {
            hasDueDate = false
            dueDate = .now
        }
        phoneNumber = Formatters.formatDebtPhoneInput(debt.phoneNumber)
        colorTag = debt.colorTag
    }

    static func toAmountString(_ amount: Double) -> String {
        Formatters.formatAmountInput(String(Int(amount.rounded())))
    }

    func dueDateValue() -> Date? {
        hasDueDate ? dueDate : nil
    }

    func amountValue() -> Double? {
        Formatters.amountValue(fromInput: totalAmountText)
    }
}

struct PaymentFormData {
    var amountText: String = ""
    var date: Date = .now
    var note: String = ""

    func amountValue() -> Double? {
        Formatters.amountValue(fromInput: amountText)
    }
}
