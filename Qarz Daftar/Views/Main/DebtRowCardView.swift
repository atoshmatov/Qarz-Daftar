import SwiftUI

struct DebtRowCardView: View {
    let debt: Debt
    let paidAmount: Double
    let remainingAmount: Double
    let isClosed: Bool
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(debt.personName.isEmpty ? L10n.text(.noName, language) : debt.personName)
                        .font(.headline)
                    Text(debt.type.shortTitle(language: language))
                        .font(.caption)
                        .foregroundStyle(debt.type.tint)
                }
                Spacer()
                Text(isClosed ? L10n.text(.closed, language) : L10n.text(.active, language))
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((isClosed ? Color.gray : debt.type.tint).opacity(0.16), in: Capsule())
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.text(.totalAmount, language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(debt.totalAmount, code: debt.currency))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.text(.remainingAmount, language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(remainingAmount, code: debt.currency))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isClosed ? .secondary : .primary)
                }
            }

            HStack {
                Text(L10n.text(.paidAmount, language) + ": " + Formatters.currency(paidAmount, code: debt.currency))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Formatters.dateFormatter.string(from: debt.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(debt.type.tint.opacity(0.2), lineWidth: 1)
        )
    }
}
