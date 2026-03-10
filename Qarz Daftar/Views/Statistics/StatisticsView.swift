import Charts
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: AppStore

    private var language: AppLanguage { store.profile.selectedLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryGrid
                    typeChartCard
                    statusChartCard
                    monthlyPaymentsCard
                }
                .padding()
            }
            .navigationTitle(L10n.text(.statistics, language))
        }
    }

    private var summaryGrid: some View {
        let summary = store.summary
        let currency = store.profile.selectedCurrency.rawValue

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            SummaryCardView(
                title: L10n.text(.summaryBorrowed, language),
                value: Formatters.currency(summary.totalBorrowed, code: currency),
                tint: .orange
            )
            SummaryCardView(
                title: L10n.text(.summaryLent, language),
                value: Formatters.currency(summary.totalLent, code: currency),
                tint: .green
            )
            SummaryCardView(
                title: L10n.text(.summaryPaid, language),
                value: Formatters.currency(summary.totalPaid, code: currency),
                tint: .blue
            )
            SummaryCardView(
                title: L10n.text(.summaryRemaining, language),
                value: Formatters.currency(summary.totalRemaining, code: currency),
                tint: .red
            )
        }
    }

    private var typeChartCard: some View {
        let data = debtTypeBreakdown

        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text(.debtByType, language))
                .font(.headline)

            Chart(data) { point in
                BarMark(
                    x: .value("Type", point.title),
                    y: .value("Amount", point.value)
                )
                .foregroundStyle(point.color)
                .cornerRadius(6)
            }
            .frame(height: 220)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var statusChartCard: some View {
        let data = debtStatusBreakdown

        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text(.debtByStatus, language))
                .font(.headline)

            Chart(data) { point in
                BarMark(
                    x: .value("Status", point.title),
                    y: .value("Count", point.value)
                )
                .foregroundStyle(point.color)
                .cornerRadius(6)
            }
            .frame(height: 200)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var monthlyPaymentsCard: some View {
        let data = monthlyPayments

        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text(.monthlyPayments, language))
                .font(.headline)

            Chart(data) { point in
                LineMark(
                    x: .value("Month", point.monthLabel),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(.blue)

                AreaMark(
                    x: .value("Month", point.monthLabel),
                    y: .value("Amount", point.amount)
                )
                .foregroundStyle(.blue.opacity(0.16))
            }
            .frame(height: 220)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var debtTypeBreakdown: [AmountPoint] {
        let totalBorrowed = store.debts
            .filter { $0.type == .borrowed }
            .reduce(0) { $0 + $1.totalAmount }

        let totalLent = store.debts
            .filter { $0.type == .lent }
            .reduce(0) { $0 + $1.totalAmount }

        return [
            AmountPoint(title: L10n.text(.borrowedType, language), value: totalBorrowed, color: .orange),
            AmountPoint(title: L10n.text(.lentType, language), value: totalLent, color: .green)
        ]
    }

    private var debtStatusBreakdown: [CountPoint] {
        let activeCount = store.debts.filter { store.isClosed($0) == false }.count
        let closedCount = store.debts.count - activeCount

        return [
            CountPoint(title: L10n.text(.active, language), value: activeCount, color: .blue),
            CountPoint(title: L10n.text(.closed, language), value: closedCount, color: .gray)
        ]
    }

    private var monthlyPayments: [MonthlyPoint] {
        let calendar = Calendar.current
        let now = Date()

        var monthStarts: [Date] = []
        for index in stride(from: 5, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .month, value: -index, to: now),
               let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
                monthStarts.append(startOfMonth)
            }
        }

        let grouped = Dictionary(grouping: store.payments) { payment in
            calendar.date(from: calendar.dateComponents([.year, .month], from: payment.date)) ?? payment.date
        }

        return monthStarts.map { monthStart in
            let amount = grouped[monthStart]?.reduce(0) { $0 + $1.amount } ?? 0
            return MonthlyPoint(
                monthLabel: Formatters.monthFormatter.string(from: monthStart),
                amount: amount
            )
        }
    }
}

private struct AmountPoint: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let color: Color
}

private struct CountPoint: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
    let color: Color
}

private struct MonthlyPoint: Identifiable {
    let id = UUID()
    let monthLabel: String
    let amount: Double
}
