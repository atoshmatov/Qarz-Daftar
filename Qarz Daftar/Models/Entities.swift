import Foundation

struct Debt: Identifiable, Codable, Hashable {
    var id: UUID
    var personName: String
    var type: DebtType
    var totalAmount: Double
    var currency: String
    var note: String
    var createdAt: Date
    var dueDate: Date?
    var phoneNumber: String
    var colorTag: String

    init(
        id: UUID = UUID(),
        personName: String,
        type: DebtType,
        totalAmount: Double,
        currency: String,
        note: String,
        createdAt: Date,
        dueDate: Date?,
        phoneNumber: String,
        colorTag: String
    ) {
        self.id = id
        self.personName = personName
        self.type = type
        self.totalAmount = totalAmount
        self.currency = currency
        self.note = note
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.phoneNumber = phoneNumber
        self.colorTag = colorTag
    }
}

struct Payment: Identifiable, Codable, Hashable {
    var id: UUID
    var debtId: UUID
    var amount: Double
    var date: Date
    var note: String

    init(id: UUID = UUID(), debtId: UUID, amount: Double, date: Date, note: String) {
        self.id = id
        self.debtId = debtId
        self.amount = amount
        self.date = date
        self.note = note
    }
}

struct UserProfile: Codable {
    var id: UUID
    var name: String
    var avatar: String
    var phoneNumber: String
    var selectedLanguage: AppLanguage
    var selectedTheme: AppTheme
    var selectedCurrency: SupportedCurrency
    var notificationsEnabled: Bool
    var appLockEnabled: Bool
    var biometricEnabled: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatar
        case phoneNumber
        case selectedLanguage
        case selectedTheme
        case selectedCurrency
        case notificationsEnabled
        case appLockEnabled
        case biometricEnabled
    }

    static let `default` = UserProfile(
        id: UUID(),
        name: "",
        avatar: "",
        phoneNumber: "",
        selectedLanguage: .uz,
        selectedTheme: .system,
        selectedCurrency: .uzs,
        notificationsEnabled: false,
        appLockEnabled: false,
        biometricEnabled: false
    )

    init(
        id: UUID = UUID(),
        name: String,
        avatar: String,
        phoneNumber: String,
        selectedLanguage: AppLanguage,
        selectedTheme: AppTheme,
        selectedCurrency: SupportedCurrency,
        notificationsEnabled: Bool,
        appLockEnabled: Bool,
        biometricEnabled: Bool
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.phoneNumber = phoneNumber
        self.selectedLanguage = selectedLanguage
        self.selectedTheme = selectedTheme
        self.selectedCurrency = selectedCurrency
        self.notificationsEnabled = notificationsEnabled
        self.appLockEnabled = appLockEnabled
        self.biometricEnabled = biometricEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        selectedLanguage = try container.decodeIfPresent(AppLanguage.self, forKey: .selectedLanguage) ?? .uz
        selectedTheme = try container.decodeIfPresent(AppTheme.self, forKey: .selectedTheme) ?? .system
        selectedCurrency = try container.decodeIfPresent(SupportedCurrency.self, forKey: .selectedCurrency) ?? .uzs
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? false
        appLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .appLockEnabled) ?? false
        biometricEnabled = try container.decodeIfPresent(Bool.self, forKey: .biometricEnabled) ?? false
    }
}

struct DashboardSummary {
    var totalBorrowed: Double
    var totalLent: Double
    var totalPaid: Double
    var totalRemaining: Double
    var receivableRemaining: Double
    var payableRemaining: Double
    var activeCount: Int
    var closedCount: Int

    static let zero = DashboardSummary(
        totalBorrowed: 0,
        totalLent: 0,
        totalPaid: 0,
        totalRemaining: 0,
        receivableRemaining: 0,
        payableRemaining: 0,
        activeCount: 0,
        closedCount: 0
    )
}

struct PersistedData: Codable {
    var debts: [Debt]
    var payments: [Payment]
    var profile: UserProfile

    private enum CodingKeys: String, CodingKey {
        case debts
        case payments
        case profile
    }

    init(debts: [Debt], payments: [Payment], profile: UserProfile) {
        self.debts = debts
        self.payments = payments
        self.profile = profile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        debts = try container.decodeIfPresent([Debt].self, forKey: .debts) ?? []
        payments = try container.decodeIfPresent([Payment].self, forKey: .payments) ?? []
        profile = try container.decodeIfPresent(UserProfile.self, forKey: .profile) ?? .default
    }
}

enum ValidationError: Error {
    case emptyName
    case invalidAmount
    case paymentTooLarge
    case debtNotFound
    case totalBelowPaid
}
