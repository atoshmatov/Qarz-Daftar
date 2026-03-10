import Foundation

enum L10nKey {
    case appName
    case mainTab
    case profileTab
    case debts
    case profile
    case emptyListTitle
    case emptyListSubtitle
    case addDebt
    case editDebt
    case addPayment
    case save
    case done
    case cancel
    case delete
    case closeDebt
    case markClosed
    case personName
    case debtType
    case amount
    case currency
    case note
    case date
    case dueDate
    case noDueDate
    case phone
    case category
    case totalAmount
    case paidAmount
    case remainingAmount
    case status
    case active
    case closed
    case createdAt
    case paymentHistory
    case noPayments
    case summaryBorrowed
    case summaryLent
    case summaryPaid
    case summaryRemaining
    case search
    case filter
    case sort
    case all
    case details
    case add
    case settings
    case language
    case theme
    case system
    case light
    case dark
    case statistics
    case receivable
    case payable
    case activeDebtsCount
    case closedDebtsCount
    case version
    case about
    case privacy
    case support
    case backupRestore
    case notifications
    case borrowedType
    case lentType
    case validationName
    case validationAmount
    case validationType
    case validationPayment
    case validationTotalBelowPaid
    case deleteConfirmation
    case deleteMessage
    case noName
    case splashSubtitle
    case editProfile
    case changePhoto
    case removePhoto
    case noPhone
    case monthlyPayments
    case debtByType
    case debtByStatus
    case notificationPromptTitle
    case notificationPromptMessage
    case enableNotifications
    case notNow
    case notificationDeniedTitle
    case notificationDeniedMessage
    case notificationReminderTitle
    case addToDebt
    case appLock
    case useBiometric
    case setPin
    case changePin
    case pinCode
    case confirmPin
    case pinHint
    case pinInvalidLength
    case pinMismatch
    case pinSaveFailed
    case unlockApp
    case enterPinToUnlock
    case unlock
    case unlockWithFaceID
    case unlockWithTouchID
    case pinIncorrect
    case biometricReason
    case biometricFailed
    case biometricUnavailableTitle
    case biometricUnavailableMessage
}

enum L10n {
    static func text(_ key: L10nKey, _ language: AppLanguage) -> String {
        switch language {
        case .uz: return uz(key)
        case .ru: return ru(key)
        case .en: return en(key)
        }
    }

    static func validationMessage(_ error: ValidationError, _ language: AppLanguage) -> String {
        switch error {
        case .emptyName:
            return text(.validationName, language)
        case .invalidAmount:
            return text(.validationAmount, language)
        case .paymentTooLarge:
            return text(.validationPayment, language)
        case .debtNotFound:
            return text(.details, language)
        case .totalBelowPaid:
            return text(.validationTotalBelowPaid, language)
        }
    }

    static func reminderBody(
        type: DebtType,
        personName: String,
        amountText: String,
        dueDateText: String,
        language: AppLanguage
    ) -> String {
        let name = personName.isEmpty ? text(.noName, language) : personName
        switch language {
        case .uz:
            if type == .borrowed {
                return "\(name)ga \(amountText) qarzni \(dueDateText) kuni qaytarish eslatmasi."
            }
            return "\(name)dan \(amountText) qarzni \(dueDateText) kuni olish eslatmasi."
        case .ru:
            if type == .borrowed {
                return "Напоминание: вернуть \(amountText) пользователю \(name) \(dueDateText)."
            }
            return "Напоминание: получить \(amountText) от \(name) \(dueDateText)."
        case .en:
            if type == .borrowed {
                return "Reminder: return \(amountText) to \(name) on \(dueDateText)."
            }
            return "Reminder: collect \(amountText) from \(name) on \(dueDateText)."
        }
    }

    private static func uz(_ key: L10nKey) -> String {
        switch key {
        case .appName: return "Qarz Daftar"
        case .mainTab: return "Asosiy"
        case .profileTab: return "Profile"
        case .debts: return "Qarzlar"
        case .profile: return "Profil"
        case .emptyListTitle: return "Hozircha qarzlar yo'q"
        case .emptyListSubtitle: return "Yangi qarz qo'shish uchun + tugmasini bosing"
        case .addDebt: return "Qarz qo'shish"
        case .editDebt: return "Qarzni tahrirlash"
        case .addPayment: return "To'lov qo'shish"
        case .save: return "Saqlash"
        case .done: return "Tayyor"
        case .cancel: return "Bekor qilish"
        case .delete: return "O'chirish"
        case .closeDebt: return "Qarz yopildi deb belgilash"
        case .markClosed: return "Yopildi"
        case .personName: return "Ism / kontakt"
        case .debtType: return "Qarz turi"
        case .amount: return "Summa"
        case .currency: return "Valyuta"
        case .note: return "Izoh"
        case .date: return "Sana"
        case .dueDate: return "Qaytarish muddati"
        case .noDueDate: return "Muddat yo'q"
        case .phone: return "Telefon"
        case .category: return "Rang / kategoriya"
        case .totalAmount: return "Umumiy summa"
        case .paidAmount: return "To'langan summa"
        case .remainingAmount: return "Qolgan summa"
        case .status: return "Status"
        case .active: return "Aktiv"
        case .closed: return "Yopilgan"
        case .createdAt: return "Yaratilgan sana"
        case .paymentHistory: return "To'lovlar tarixi"
        case .noPayments: return "To'lovlar yo'q"
        case .summaryBorrowed: return "Jami qarz olgan"
        case .summaryLent: return "Jami qarz bergan"
        case .summaryPaid: return "Jami to'langan"
        case .summaryRemaining: return "Jami qolgan"
        case .search: return "Qidirish"
        case .filter: return "Filter"
        case .sort: return "Sort"
        case .all: return "Hammasi"
        case .details: return "Batafsil"
        case .add: return "Qo'shish"
        case .settings: return "Sozlamalar"
        case .language: return "Til"
        case .theme: return "Mavzu"
        case .system: return "Tizim"
        case .light: return "Kunduzgi"
        case .dark: return "Tungi"
        case .statistics: return "Statistikalar"
        case .receivable: return "Jami olinadigan"
        case .payable: return "Jami beriladigan"
        case .activeDebtsCount: return "Aktiv qarzlar soni"
        case .closedDebtsCount: return "Yopilgan qarzlar soni"
        case .version: return "Ilova versiyasi"
        case .about: return "About app"
        case .privacy: return "Privacy Policy"
        case .support: return "Support / Feedback"
        case .backupRestore: return "Backup / Restore"
        case .notifications: return "Bildirishnomalar"
        case .borrowedType: return "Men qarz oldim"
        case .lentType: return "Men qarz berdim"
        case .validationName: return "Ism bo'sh bo'lmasligi kerak"
        case .validationAmount: return "Summa 0 dan katta bo'lishi kerak"
        case .validationType: return "Qarz turi tanlanishi kerak"
        case .validationPayment: return "To'lov summasi qolgan summadan katta bo'lmasligi kerak"
        case .validationTotalBelowPaid: return "Umumiy summa to'langan summadan kichik bo'la olmaydi"
        case .deleteConfirmation: return "Yozuvni o'chirish"
        case .deleteMessage: return "Bu amalni qaytarib bo'lmaydi"
        case .noName: return "Ism kiritilmagan"
        case .splashSubtitle: return "Qarzlaringizni tartibda saqlang"
        case .editProfile: return "Profilni tahrirlash"
        case .changePhoto: return "Rasmni o'zgartirish"
        case .removePhoto: return "Rasmni olib tashlash"
        case .noPhone: return "Telefon kiritilmagan"
        case .monthlyPayments: return "Oylik to'lovlar"
        case .debtByType: return "Qarz turlari bo'yicha"
        case .debtByStatus: return "Status bo'yicha"
        case .notificationPromptTitle: return "Bildirishnomalarni yoqish"
        case .notificationPromptMessage: return "Qaytarish muddati kiritilgan qarzlar bo'yicha o'z vaqtida eslatma olasiz."
        case .enableNotifications: return "Yoqish"
        case .notNow: return "Hozir emas"
        case .notificationDeniedTitle: return "Bildirishnoma o'chirilgan"
        case .notificationDeniedMessage: return "Eslatmalar ishlashi uchun iPhone sozlamalaridan bildirishnomalarga ruxsat bering."
        case .notificationReminderTitle: return "Qarz eslatmasi"
        case .addToDebt: return "Qarzga qo'shish"
        case .appLock: return "Ilova qulfi"
        case .useBiometric: return "Biometrik kirish"
        case .setPin: return "PIN o'rnatish"
        case .changePin: return "PINni o'zgartirish"
        case .pinCode: return "PIN kod"
        case .confirmPin: return "PINni tasdiqlang"
        case .pinHint: return "4 xonali PIN kod kiriting"
        case .pinInvalidLength: return "PIN 4 xonadan iborat bo'lishi kerak"
        case .pinMismatch: return "PIN kodlar mos kelmadi"
        case .pinSaveFailed: return "PIN saqlanmadi, qaytadan urinib ko'ring"
        case .unlockApp: return "Ilovani ochish"
        case .enterPinToUnlock: return "PIN kiriting"
        case .unlock: return "Ochish"
        case .unlockWithFaceID: return "Face ID bilan ochish"
        case .unlockWithTouchID: return "Touch ID bilan ochish"
        case .pinIncorrect: return "PIN noto'g'ri"
        case .biometricReason: return "Ilovaga kirish uchun tasdiqlang"
        case .biometricFailed: return "Biometrik tasdiqlanmadi, PIN kiriting"
        case .biometricUnavailableTitle: return "Biometrik kirish mavjud emas"
        case .biometricUnavailableMessage: return "Qurilmada Face ID/Touch ID yoqilmagan yoki mavjud emas."
        }
    }

    private static func ru(_ key: L10nKey) -> String {
        switch key {
        case .appName: return "Qarz Daftar"
        case .mainTab: return "Главная"
        case .profileTab: return "Профиль"
        case .debts: return "Долги"
        case .profile: return "Профиль"
        case .emptyListTitle: return "Пока нет долгов"
        case .emptyListSubtitle: return "Нажмите +, чтобы добавить запись"
        case .addDebt: return "Добавить долг"
        case .editDebt: return "Редактировать долг"
        case .addPayment: return "Добавить платеж"
        case .save: return "Сохранить"
        case .done: return "Готово"
        case .cancel: return "Отмена"
        case .delete: return "Удалить"
        case .closeDebt: return "Отметить как закрытый"
        case .markClosed: return "Закрыт"
        case .personName: return "Имя / контакт"
        case .debtType: return "Тип долга"
        case .amount: return "Сумма"
        case .currency: return "Валюта"
        case .note: return "Комментарий"
        case .date: return "Дата"
        case .dueDate: return "Срок возврата"
        case .noDueDate: return "Без срока"
        case .phone: return "Телефон"
        case .category: return "Цвет / категория"
        case .totalAmount: return "Общая сумма"
        case .paidAmount: return "Оплачено"
        case .remainingAmount: return "Остаток"
        case .status: return "Статус"
        case .active: return "Активный"
        case .closed: return "Закрыт"
        case .createdAt: return "Дата создания"
        case .paymentHistory: return "История платежей"
        case .noPayments: return "Платежей нет"
        case .summaryBorrowed: return "Всего взял"
        case .summaryLent: return "Всего дал"
        case .summaryPaid: return "Всего оплачено"
        case .summaryRemaining: return "Всего осталось"
        case .search: return "Поиск"
        case .filter: return "Фильтр"
        case .sort: return "Сортировка"
        case .all: return "Все"
        case .details: return "Детали"
        case .add: return "Добавить"
        case .settings: return "Настройки"
        case .language: return "Язык"
        case .theme: return "Тема"
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Темная"
        case .statistics: return "Статистика"
        case .receivable: return "К получению"
        case .payable: return "К выплате"
        case .activeDebtsCount: return "Активных долгов"
        case .closedDebtsCount: return "Закрытых долгов"
        case .version: return "Версия приложения"
        case .about: return "О приложении"
        case .privacy: return "Политика конфиденциальности"
        case .support: return "Поддержка / Обратная связь"
        case .backupRestore: return "Резервная копия / Восстановление"
        case .notifications: return "Уведомления"
        case .borrowedType: return "Я взял в долг"
        case .lentType: return "Я дал в долг"
        case .validationName: return "Имя не может быть пустым"
        case .validationAmount: return "Сумма должна быть больше 0"
        case .validationType: return "Выберите тип долга"
        case .validationPayment: return "Платеж не может быть больше остатка"
        case .validationTotalBelowPaid: return "Общая сумма не может быть меньше оплаченной"
        case .deleteConfirmation: return "Удалить запись"
        case .deleteMessage: return "Это действие нельзя отменить"
        case .noName: return "Имя не указано"
        case .splashSubtitle: return "Держите долги под контролем"
        case .editProfile: return "Редактировать профиль"
        case .changePhoto: return "Изменить фото"
        case .removePhoto: return "Удалить фото"
        case .noPhone: return "Телефон не указан"
        case .monthlyPayments: return "Платежи по месяцам"
        case .debtByType: return "По типу долга"
        case .debtByStatus: return "По статусу"
        case .notificationPromptTitle: return "Включить уведомления"
        case .notificationPromptMessage: return "Приложение будет напоминать о долгах с указанным сроком возврата."
        case .enableNotifications: return "Включить"
        case .notNow: return "Не сейчас"
        case .notificationDeniedTitle: return "Уведомления выключены"
        case .notificationDeniedMessage: return "Разрешите уведомления в настройках iPhone, чтобы получать напоминания."
        case .notificationReminderTitle: return "Напоминание о долге"
        case .addToDebt: return "Добавить к долгу"
        case .appLock: return "Блокировка приложения"
        case .useBiometric: return "Биометрический вход"
        case .setPin: return "Установить PIN"
        case .changePin: return "Изменить PIN"
        case .pinCode: return "PIN-код"
        case .confirmPin: return "Подтвердите PIN"
        case .pinHint: return "Введите 4-значный PIN-код"
        case .pinInvalidLength: return "PIN должен состоять из 4 цифр"
        case .pinMismatch: return "PIN-коды не совпадают"
        case .pinSaveFailed: return "Не удалось сохранить PIN, попробуйте снова"
        case .unlockApp: return "Разблокировать приложение"
        case .enterPinToUnlock: return "Введите PIN"
        case .unlock: return "Разблокировать"
        case .unlockWithFaceID: return "Разблокировать через Face ID"
        case .unlockWithTouchID: return "Разблокировать через Touch ID"
        case .pinIncorrect: return "Неверный PIN"
        case .biometricReason: return "Подтвердите вход в приложение"
        case .biometricFailed: return "Биометрия не подтверждена, введите PIN"
        case .biometricUnavailableTitle: return "Биометрия недоступна"
        case .biometricUnavailableMessage: return "Face ID/Touch ID не настроен или недоступен на устройстве."
        }
    }

    private static func en(_ key: L10nKey) -> String {
        switch key {
        case .appName: return "Qarz Daftar"
        case .mainTab: return "Home"
        case .profileTab: return "Profile"
        case .debts: return "Debts"
        case .profile: return "Profile"
        case .emptyListTitle: return "No debts yet"
        case .emptyListSubtitle: return "Tap + to add your first debt"
        case .addDebt: return "Add Debt"
        case .editDebt: return "Edit Debt"
        case .addPayment: return "Add Payment"
        case .save: return "Save"
        case .done: return "Done"
        case .cancel: return "Cancel"
        case .delete: return "Delete"
        case .closeDebt: return "Mark as closed"
        case .markClosed: return "Closed"
        case .personName: return "Name / contact"
        case .debtType: return "Debt type"
        case .amount: return "Amount"
        case .currency: return "Currency"
        case .note: return "Note"
        case .date: return "Date"
        case .dueDate: return "Due date"
        case .noDueDate: return "No due date"
        case .phone: return "Phone"
        case .category: return "Color / category"
        case .totalAmount: return "Total amount"
        case .paidAmount: return "Paid amount"
        case .remainingAmount: return "Remaining amount"
        case .status: return "Status"
        case .active: return "Active"
        case .closed: return "Closed"
        case .createdAt: return "Created at"
        case .paymentHistory: return "Payment history"
        case .noPayments: return "No payments"
        case .summaryBorrowed: return "Total borrowed"
        case .summaryLent: return "Total lent"
        case .summaryPaid: return "Total paid"
        case .summaryRemaining: return "Total remaining"
        case .search: return "Search"
        case .filter: return "Filter"
        case .sort: return "Sort"
        case .all: return "All"
        case .details: return "Details"
        case .add: return "Add"
        case .settings: return "Settings"
        case .language: return "Language"
        case .theme: return "Theme"
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .statistics: return "Statistics"
        case .receivable: return "Receivable"
        case .payable: return "Payable"
        case .activeDebtsCount: return "Active debts"
        case .closedDebtsCount: return "Closed debts"
        case .version: return "App version"
        case .about: return "About app"
        case .privacy: return "Privacy policy"
        case .support: return "Support / Feedback"
        case .backupRestore: return "Backup / Restore"
        case .notifications: return "Notifications"
        case .borrowedType: return "I borrowed"
        case .lentType: return "I lent"
        case .validationName: return "Name cannot be empty"
        case .validationAmount: return "Amount must be greater than 0"
        case .validationType: return "Debt type is required"
        case .validationPayment: return "Payment cannot exceed remaining amount"
        case .validationTotalBelowPaid: return "Total amount cannot be lower than paid amount"
        case .deleteConfirmation: return "Delete debt"
        case .deleteMessage: return "This action cannot be undone"
        case .noName: return "No name"
        case .splashSubtitle: return "Track debts with clarity"
        case .editProfile: return "Edit profile"
        case .changePhoto: return "Change photo"
        case .removePhoto: return "Remove photo"
        case .noPhone: return "Phone not added"
        case .monthlyPayments: return "Monthly payments"
        case .debtByType: return "By debt type"
        case .debtByStatus: return "By status"
        case .notificationPromptTitle: return "Enable notifications"
        case .notificationPromptMessage: return "Get reminders for debts that have a due date."
        case .enableNotifications: return "Enable"
        case .notNow: return "Not now"
        case .notificationDeniedTitle: return "Notifications disabled"
        case .notificationDeniedMessage: return "Enable notifications in iPhone Settings to receive reminders."
        case .notificationReminderTitle: return "Debt reminder"
        case .addToDebt: return "Add to debt"
        case .appLock: return "App lock"
        case .useBiometric: return "Use biometric"
        case .setPin: return "Set PIN"
        case .changePin: return "Change PIN"
        case .pinCode: return "PIN code"
        case .confirmPin: return "Confirm PIN"
        case .pinHint: return "Enter a 4-digit PIN code"
        case .pinInvalidLength: return "PIN must be 4 digits"
        case .pinMismatch: return "PIN codes do not match"
        case .pinSaveFailed: return "Failed to save PIN. Please try again."
        case .unlockApp: return "Unlock app"
        case .enterPinToUnlock: return "Enter PIN"
        case .unlock: return "Unlock"
        case .unlockWithFaceID: return "Unlock with Face ID"
        case .unlockWithTouchID: return "Unlock with Touch ID"
        case .pinIncorrect: return "Incorrect PIN"
        case .biometricReason: return "Authenticate to open the app"
        case .biometricFailed: return "Biometric authentication failed. Enter PIN."
        case .biometricUnavailableTitle: return "Biometric unavailable"
        case .biometricUnavailableMessage: return "Face ID/Touch ID is unavailable or not configured on this device."
        }
    }
}
