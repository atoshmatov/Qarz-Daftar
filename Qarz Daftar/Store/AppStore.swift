import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var debts: [Debt] = [] {
        didSet {
            recalculateSummary()
            saveIfNeeded()
        }
    }
    @Published var payments: [Payment] = [] {
        didSet {
            recalculatePaymentTotals()
            recalculateSummary()
            saveIfNeeded()
        }
    }
    @Published var profile: UserProfile = .default {
        didSet {
            if profile.notificationsEnabled != oldValue.notificationsEnabled {
                if profile.notificationsEnabled {
                    syncAllDebtReminders()
                } else {
                    Task {
                        await NotificationService.removeAllDebtReminders()
                    }
                }
            }
            saveIfNeeded()
        }
    }

    private var hasLoaded = false
    private let saveQueue = DispatchQueue(label: "uz.toshmatov.qarzdaftar.persistence", qos: .utility)
    private var pendingSaveWorkItem: DispatchWorkItem?
    private var paymentTotalsByDebtID: [UUID: Double] = [:]
    private var summaryCache: DashboardSummary = .zero

    init() {
        load()
        recalculateSummary()
        hasLoaded = true
        if profile.notificationsEnabled {
            syncAllDebtReminders()
        }
    }

    func addDebt(
        personName: String,
        type: DebtType,
        totalAmount: Double,
        currency: SupportedCurrency,
        note: String,
        createdAt: Date,
        dueDate: Date?,
        phoneNumber: String,
        colorTag: String
    ) throws {
        let cleanedName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedName.isEmpty == false else {
            throw ValidationError.emptyName
        }
        guard totalAmount > 0 else {
            throw ValidationError.invalidAmount
        }

        let debt = Debt(
            personName: cleanedName,
            type: type,
            totalAmount: totalAmount,
            currency: currency.rawValue,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: createdAt,
            dueDate: dueDate,
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            colorTag: colorTag.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        debts.append(debt)
        syncReminder(for: debt)
    }

    func updateDebt(
        id: UUID,
        personName: String,
        type: DebtType,
        totalAmount: Double,
        currency: SupportedCurrency,
        note: String,
        createdAt: Date,
        dueDate: Date?,
        phoneNumber: String,
        colorTag: String
    ) throws {
        let cleanedName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedName.isEmpty == false else {
            throw ValidationError.emptyName
        }
        guard totalAmount > 0 else {
            throw ValidationError.invalidAmount
        }

        guard let index = debts.firstIndex(where: { $0.id == id }) else {
            throw ValidationError.debtNotFound
        }

        let alreadyPaid = paidAmount(for: id)
        guard totalAmount + 0.0001 >= alreadyPaid else {
            throw ValidationError.totalBelowPaid
        }

        debts[index].personName = cleanedName
        debts[index].type = type
        debts[index].totalAmount = totalAmount
        debts[index].currency = currency.rawValue
        debts[index].note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        debts[index].createdAt = createdAt
        debts[index].dueDate = dueDate
        debts[index].phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        debts[index].colorTag = colorTag.trimmingCharacters(in: .whitespacesAndNewlines)
        syncReminder(for: debts[index])
    }

    func deleteDebt(id: UUID) {
        debts.removeAll { $0.id == id }
        payments.removeAll { $0.debtId == id }
        Task {
            NotificationService.removeReminder(for: id)
        }
    }

    func addPayment(debtId: UUID, amount: Double, date: Date, note: String) throws {
        guard amount > 0 else {
            throw ValidationError.invalidAmount
        }
        guard debts.contains(where: { $0.id == debtId }) else {
            throw ValidationError.debtNotFound
        }

        let remaining = remainingAmount(forDebtId: debtId)
        guard amount <= remaining + 0.0001 else {
            throw ValidationError.paymentTooLarge
        }

        let payment = Payment(
            debtId: debtId,
            amount: amount,
            date: date,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        payments.append(payment)

        if let debt = debt(by: debtId) {
            syncReminder(for: debt)
        }
    }

    func addToDebt(id: UUID, amount: Double) throws {
        guard amount > 0 else {
            throw ValidationError.invalidAmount
        }
        guard let index = debts.firstIndex(where: { $0.id == id }) else {
            throw ValidationError.debtNotFound
        }

        debts[index].totalAmount += amount
        syncReminder(for: debts[index])
    }

    func markDebtClosed(id: UUID) throws {
        guard debts.contains(where: { $0.id == id }) else {
            throw ValidationError.debtNotFound
        }

        let remaining = remainingAmount(forDebtId: id)
        guard remaining > 0 else { return }

        let payment = Payment(
            debtId: id,
            amount: remaining,
            date: .now,
            note: "Manual close"
        )
        payments.append(payment)

        if let debt = debt(by: id) {
            syncReminder(for: debt)
        }
    }

    func debt(by id: UUID) -> Debt? {
        debts.first { $0.id == id }
    }

    func payments(for debtId: UUID) -> [Payment] {
        payments
            .filter { $0.debtId == debtId }
            .sorted { $0.date > $1.date }
    }

    func paidAmount(for debtId: UUID) -> Double {
        paymentTotalsByDebtID[debtId] ?? 0
    }

    func remainingAmount(for debt: Debt) -> Double {
        let paid = paidAmount(for: debt.id)
        return max(debt.totalAmount - paid, 0)
    }

    func remainingAmount(forDebtId debtId: UUID) -> Double {
        guard let debt = debt(by: debtId) else { return 0 }
        return remainingAmount(for: debt)
    }

    func isClosed(_ debt: Debt) -> Bool {
        remainingAmount(for: debt) <= 0.0001
    }

    func filteredDebts(searchText: String, filter: DebtFilter, sort: DebtSort) -> [Debt] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        var result = debts.filter { debt in
            if query.isEmpty == false {
                let matches = debt.personName.localizedCaseInsensitiveContains(query)
                    || debt.note.localizedCaseInsensitiveContains(query)
                    || debt.phoneNumber.localizedCaseInsensitiveContains(query)
                guard matches else { return false }
            }

            switch filter {
            case .all:
                return true
            case .borrowed:
                return debt.type == .borrowed
            case .lent:
                return debt.type == .lent
            case .active:
                return isClosed(debt) == false
            case .closed:
                return isClosed(debt)
            }
        }

        switch sort {
        case .date:
            result.sort { $0.createdAt > $1.createdAt }
        case .amount:
            result.sort { $0.totalAmount > $1.totalAmount }
        case .name:
            result.sort { $0.personName.localizedCaseInsensitiveCompare($1.personName) == .orderedAscending }
        }

        return result
    }

    var summary: DashboardSummary {
        summaryCache
    }

    private func saveIfNeeded() {
        guard hasLoaded else { return }
        let snapshot = PersistedData(debts: debts, payments: payments, profile: profile)
        scheduleSave(snapshot)
    }

    private func scheduleSave(_ payload: PersistedData) {
        pendingSaveWorkItem?.cancel()

        let work = DispatchWorkItem {
            persistDataToDisk(payload)
        }
        pendingSaveWorkItem = work
        saveQueue.asyncAfter(deadline: .now() + 0.15, execute: work)
    }

    private func recalculatePaymentTotals() {
        paymentTotalsByDebtID = Dictionary(grouping: payments, by: \.debtId)
            .mapValues { debtPayments in
                debtPayments.reduce(0) { $0 + $1.amount }
            }
    }

    private func recalculateSummary() {
        guard debts.isEmpty == false else {
            summaryCache = .zero
            return
        }

        var totalBorrowed = 0.0
        var totalLent = 0.0
        var totalRemaining = 0.0
        var receivable = 0.0
        var payable = 0.0
        var activeCount = 0

        for debt in debts {
            if debt.type == .borrowed {
                totalBorrowed += debt.totalAmount
            } else {
                totalLent += debt.totalAmount
            }

            let paid = paymentTotalsByDebtID[debt.id] ?? 0
            let remaining = max(debt.totalAmount - paid, 0)
            totalRemaining += remaining

            if debt.type == .lent {
                receivable += remaining
            } else {
                payable += remaining
            }

            if remaining > 0.0001 {
                activeCount += 1
            }
        }

        summaryCache = DashboardSummary(
            totalBorrowed: totalBorrowed,
            totalLent: totalLent,
            totalPaid: payments.reduce(0) { $0 + $1.amount },
            totalRemaining: totalRemaining,
            receivableRemaining: receivable,
            payableRemaining: payable,
            activeCount: activeCount,
            closedCount: max(debts.count - activeCount, 0)
        )
    }

    private func syncReminder(for debt: Debt) {
        guard profile.notificationsEnabled else { return }
        let remaining = remainingAmount(for: debt)
        let selectedLanguage = profile.selectedLanguage
        Task {
            await NotificationService.upsertReminder(
                for: debt,
                remainingAmount: remaining,
                language: selectedLanguage
            )
        }
    }

    private func syncAllDebtReminders() {
        guard profile.notificationsEnabled else { return }
        let debtsSnapshot = debts
        let paymentTotalsSnapshot = paymentTotalsByDebtID
        let selectedLanguage = profile.selectedLanguage
        Task {
            for debt in debtsSnapshot {
                let paid = paymentTotalsSnapshot[debt.id] ?? 0
                let remaining = max(debt.totalAmount - paid, 0)
                await NotificationService.upsertReminder(
                    for: debt,
                    remainingAmount: remaining,
                    language: selectedLanguage
                )
            }
        }
    }

    private func load() {
        let fileManager = FileManager.default

        do {
            let directoryURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let dataURL = directoryURL.appendingPathComponent("qarz-daftar.json")

            guard fileManager.fileExists(atPath: dataURL.path) else {
                debts = []
                payments = []
                profile = .default
                return
            }

            let data = try Data(contentsOf: dataURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(PersistedData.self, from: data)
            debts = decoded.debts
            payments = decoded.payments
            profile = decoded.profile
            recalculatePaymentTotals()
        } catch {
            debts = []
            payments = []
            profile = .default
            recalculatePaymentTotals()
        }
    }

}

private func persistDataToDisk(_ payload: PersistedData) {
    let fileManager = FileManager.default

    do {
        let directoryURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let dataURL = directoryURL.appendingPathComponent("qarz-daftar.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let encoded = try encoder.encode(payload)
        try encoded.write(to: dataURL, options: .atomic)
    } catch {
        // Keep app responsive even if persistence fails.
    }
}
