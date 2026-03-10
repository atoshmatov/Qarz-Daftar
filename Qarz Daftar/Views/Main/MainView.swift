import SwiftUI

struct MainView: View {
    @EnvironmentObject private var store: AppStore

    @State private var searchText: String = ""
    @State private var filter: DebtFilter = .all
    @State private var sort: DebtSort = .date
    @State private var isAddSheetPresented = false
    @State private var displayedDebts: [Debt] = []

    private var language: AppLanguage { store.profile.selectedLanguage }
    private var summary: DashboardSummary { store.summary }

    private var summaryCurrencyCode: String {
        store.profile.selectedCurrency.rawValue
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summarySection
                    controlsSection

                    if displayedDebts.isEmpty {
                        EmptyStateView(
                            title: L10n.text(.emptyListTitle, language),
                            subtitle: L10n.text(.emptyListSubtitle, language)
                        )
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(displayedDebts) { debt in
                                let paid = store.paidAmount(for: debt.id)
                                let remaining = max(debt.totalAmount - paid, 0)
                                let closed = remaining <= 0.0001

                                NavigationLink(value: debt.id) {
                                    DebtRowCardView(
                                        debt: debt,
                                        paidAmount: paid,
                                        remainingAmount: remaining,
                                        isClosed: closed,
                                        language: language
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(L10n.text(.debts, language))
            .searchable(text: $searchText, prompt: L10n.text(.search, language))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.text(.done, language)) {
                        Keyboard.dismiss()
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isAddSheetPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor, in: Circle())
                        .shadow(radius: 8, y: 4)
                }
                .padding()
                .accessibilityLabel(L10n.text(.addDebt, language))
            }
            .sheet(isPresented: $isAddSheetPresented) {
                AddDebtView()
            }
            .navigationDestination(for: UUID.self) { debtID in
                DebtDetailView(debtID: debtID)
            }
            .onAppear {
                reloadDebts()
            }
            .onChange(of: searchText) { _ in
                reloadDebts()
            }
            .onChange(of: filter) { _ in
                reloadDebts()
            }
            .onChange(of: sort) { _ in
                reloadDebts()
            }
            .onChange(of: store.debts) { _ in
                reloadDebts()
            }
            .onChange(of: store.payments) { _ in
                reloadDebts()
            }
        }
    }

    private func reloadDebts() {
        displayedDebts = store.filteredDebts(searchText: searchText, filter: filter, sort: sort)
    }

    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            SummaryCardView(
                title: L10n.text(.summaryBorrowed, language),
                value: Formatters.currency(summary.totalBorrowed, code: summaryCurrencyCode),
                tint: .orange
            )
            SummaryCardView(
                title: L10n.text(.summaryLent, language),
                value: Formatters.currency(summary.totalLent, code: summaryCurrencyCode),
                tint: .green
            )
            SummaryCardView(
                title: L10n.text(.summaryPaid, language),
                value: Formatters.currency(summary.totalPaid, code: summaryCurrencyCode),
                tint: .blue
            )
            SummaryCardView(
                title: L10n.text(.summaryRemaining, language),
                value: Formatters.currency(summary.totalRemaining, code: summaryCurrencyCode),
                tint: .red
            )
        }
    }

    private var controlsSection: some View {
        HStack {
            Menu {
                Picker(L10n.text(.filter, language), selection: $filter) {
                    ForEach(DebtFilter.allCases) { option in
                        Text(option.title(language: language)).tag(option)
                    }
                }
            } label: {
                Label(L10n.text(.filter, language), systemImage: "line.3.horizontal.decrease.circle")
                    .font(.subheadline)
            }

            Spacer()

            Menu {
                Picker(L10n.text(.sort, language), selection: $sort) {
                    ForEach(DebtSort.allCases) { option in
                        Text(option.title(language: language)).tag(option)
                    }
                }
            } label: {
                Label(L10n.text(.sort, language), systemImage: "arrow.up.arrow.down.circle")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 2)
    }
}
