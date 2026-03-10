import Foundation
import UserNotifications

enum NotificationService {
    private static let center = UNUserNotificationCenter.current()
    private static let reminderPrefix = "debt-reminder-"

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func upsertReminder(for debt: Debt, remainingAmount: Double, language: AppLanguage) async {
        removeReminder(for: debt.id)

        guard let dueDate = debt.dueDate else { return }
        guard remainingAmount > 0.0001 else { return }

        let reminderDate = normalizedReminderDate(from: dueDate)
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = L10n.text(.notificationReminderTitle, language)
        content.body = L10n.reminderBody(
            type: debt.type,
            personName: debt.personName,
            amountText: Formatters.currency(remainingAmount, code: debt.currency),
            dueDateText: Formatters.dateFormatter.string(from: dueDate),
            language: language
        )
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: debt.id),
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    static func removeReminder(for debtID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier(for: debtID)])
        center.removeDeliveredNotifications(withIdentifiers: [reminderIdentifier(for: debtID)])
    }

    static func removeAllDebtReminders() async {
        let pendingRequests = await pendingReminderIdentifiers()
        center.removePendingNotificationRequests(withIdentifiers: pendingRequests)
        center.removeDeliveredNotifications(withIdentifiers: pendingRequests)
    }

    private static func pendingReminderIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                let ids = requests
                    .map(\.identifier)
                    .filter { $0.hasPrefix(reminderPrefix) }
                continuation.resume(returning: ids)
            }
        }
    }

    private static func reminderIdentifier(for debtID: UUID) -> String {
        reminderPrefix + debtID.uuidString
    }

    private static func normalizedReminderDate(from dueDate: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        components.hour = 9
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? dueDate
    }
}
