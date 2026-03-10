import Foundation

enum Formatters {
    private static let amountFormatterLock = NSLock()
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func currency(_ amount: Double, code: String) -> String {
        let amountText = formattedAmount(amount)
        let suffix = currencySuffix(for: code)
        return amountText + " " + suffix
    }

    static func formattedAmount(_ amount: Double) -> String {
        amountFormatterLock.lock()
        defer { amountFormatterLock.unlock() }
        return amountFormatter.string(from: NSNumber(value: amount)) ?? String(Int(amount.rounded()))
    }

    static func formatAmountInput(_ value: String, maxDigits: Int = 12) -> String {
        let digits = String(value.filter { $0.isNumber }.prefix(maxDigits))
        guard digits.isEmpty == false else { return "" }
        return groupedDigits(digits)
    }

    static func amountValue(fromInput value: String) -> Double? {
        let digits = value.filter { $0.isNumber }
        guard digits.isEmpty == false else { return nil }
        return Double(digits)
    }

    static func phoneDigits(_ value: String) -> String {
        value.filter { $0.isNumber }
    }

    static func formattedPhone(_ value: String) -> String {
        let digits = phoneDigits(value)
        guard digits.isEmpty == false else { return "" }

        if digits.count == 9 {
            return formatUzbekPhone(fromDigits: "998" + digits)
        }

        if digits.hasPrefix("998"), digits.count <= 12 {
            return formatUzbekPhone(fromDigits: String(digits.prefix(12)))
        }

        return "+" + digits
    }

    static func editableProfilePhone(_ value: String) -> String {
        let digits = phoneDigits(value)
        guard digits.isEmpty == false else { return "+998" }
        return formatProfilePhoneInput(digits)
    }

    static func formatProfilePhoneInput(_ value: String) -> String {
        let digits = phoneDigits(value)
        let normalizedDigits: String

        if digits.isEmpty {
            normalizedDigits = "998"
        } else if digits.hasPrefix("998") {
            normalizedDigits = String(digits.prefix(12))
        } else {
            normalizedDigits = "998" + String(digits.prefix(9))
        }

        return formatUzbekPhone(fromDigits: normalizedDigits)
    }

    static func profilePhoneStorageDigits(_ value: String) -> String {
        let digits = phoneDigits(formatProfilePhoneInput(value))
        if digits.count <= 3 {
            return ""
        }
        return digits
    }

    static func formatDebtPhoneInput(_ value: String) -> String {
        let digits = phoneDigits(value)
        guard digits.isEmpty == false else { return "" }
        return formatProfilePhoneInput(value)
    }

    static func debtPhoneStorageDigits(_ value: String) -> String {
        let digits = phoneDigits(formatDebtPhoneInput(value))
        if digits.count <= 3 {
            return ""
        }
        return digits
    }

    private static func currencySuffix(for code: String) -> String {
        let normalized = code.uppercased()
        switch normalized {
        case "UZS":
            return "so'm"
        default:
            return normalized
        }
    }

    private static func groupedDigits(_ digits: String) -> String {
        let reversedDigits = Array(digits.reversed())
        var output: [Character] = []

        for (index, digit) in reversedDigits.enumerated() {
            if index > 0, index % 3 == 0 {
                output.append(" ")
            }
            output.append(digit)
        }

        return String(output.reversed())
    }

    private static func formatUzbekPhone(fromDigits digits: String) -> String {
        let normalized = String(digits.prefix(12))
        let country = "+998"
        guard normalized.count > 3 else { return country }

        let localDigits = Array(normalized.dropFirst(3))
        let groups = [2, 3, 2, 2]

        var result = country
        var startIndex = 0

        for groupSize in groups {
            if startIndex >= localDigits.count { break }
            let endIndex = min(startIndex + groupSize, localDigits.count)
            result += " "
            result += String(localDigits[startIndex..<endIndex])
            startIndex = endIndex
        }

        return result
    }

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
}
