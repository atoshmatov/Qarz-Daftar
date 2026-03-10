import SwiftUI

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case uz
    case ru
    case en

    var id: Self { self }

    var title: String {
        switch self {
        case .uz: return "O'zbekcha"
        case .ru: return "Русский"
        case .en: return "English"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum DebtType: String, Codable, CaseIterable, Identifiable {
    case borrowed
    case lent

    var id: Self { self }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.borrowed, .uz): return "Men qarz oldim"
        case (.borrowed, .ru): return "Я взял в долг"
        case (.borrowed, .en): return "I borrowed"
        case (.lent, .uz): return "Men qarz berdim"
        case (.lent, .ru): return "Я дал в долг"
        case (.lent, .en): return "I lent"
        }
    }

    func shortTitle(language: AppLanguage) -> String {
        switch (self, language) {
        case (.borrowed, .uz): return "Olingan"
        case (.borrowed, .ru): return "Взял"
        case (.borrowed, .en): return "Borrowed"
        case (.lent, .uz): return "Berilgan"
        case (.lent, .ru): return "Дал"
        case (.lent, .en): return "Lent"
        }
    }

    var tint: Color {
        switch self {
        case .borrowed: return .orange
        case .lent: return .green
        }
    }
}

enum DebtFilter: String, CaseIterable, Identifiable {
    case all
    case borrowed
    case lent
    case active
    case closed

    var id: Self { self }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.all, .uz): return "Hammasi"
        case (.all, .ru): return "Все"
        case (.all, .en): return "All"
        case (.borrowed, .uz): return "Qarz olganlar"
        case (.borrowed, .ru): return "Я взял"
        case (.borrowed, .en): return "Borrowed"
        case (.lent, .uz): return "Qarz berganlar"
        case (.lent, .ru): return "Я дал"
        case (.lent, .en): return "Lent"
        case (.active, .uz): return "Aktivlar"
        case (.active, .ru): return "Активные"
        case (.active, .en): return "Active"
        case (.closed, .uz): return "Yopilganlar"
        case (.closed, .ru): return "Закрытые"
        case (.closed, .en): return "Closed"
        }
    }
}

enum DebtSort: String, CaseIterable, Identifiable {
    case date
    case amount
    case name

    var id: Self { self }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.date, .uz): return "Sana bo'yicha"
        case (.date, .ru): return "По дате"
        case (.date, .en): return "By date"
        case (.amount, .uz): return "Summa bo'yicha"
        case (.amount, .ru): return "По сумме"
        case (.amount, .en): return "By amount"
        case (.name, .uz): return "Ism bo'yicha"
        case (.name, .ru): return "По имени"
        case (.name, .en): return "By name"
        }
    }
}

enum SupportedCurrency: String, CaseIterable, Codable, Identifiable {
    case uzs = "UZS"
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"

    var id: Self { self }
}
