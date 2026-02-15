import SwiftUI
import SwiftData

/// Tela de histórico de ações
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToggleHistoryEntry.timestamp, order: .reverse) private var entries: [ToggleHistoryEntry]

    @State private var selectedFilter: RadioServiceType?
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle(String(localized: "History"))
            .toolbar {
                if !entries.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(String(localized: "Clear all"), systemImage: "trash", role: .destructive) {
                                showingClearConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }

                    ToolbarItem(placement: .topBarLeading) {
                        filterMenu
                    }
                }
            }
            .alert(String(localized: "Clear History"), isPresented: $showingClearConfirmation) {
                Button(String(localized: "Cancel"), role: .cancel) {}
                Button(String(localized: "Clear"), role: .destructive) {
                    clearHistory()
                }
            } message: {
                Text("Are you sure you want to delete all history?", comment: "Clear history confirmation message")
            }
        }
    }

    // MARK: - Filter Menu

    private var filterMenu: some View {
        Menu {
            Button {
                selectedFilter = nil
            } label: {
                HStack {
                    Text("All", comment: "Filter: show all entries")
                    if selectedFilter == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(RadioServiceType.allCases) { service in
                Button {
                    selectedFilter = service
                } label: {
                    HStack {
                        Label(service.displayName, systemImage: service.icon)
                        if selectedFilter == service {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                if let filter = selectedFilter {
                    Text(filter.displayName)
                        .font(.caption)
                }
            }
        }
    }

    // MARK: - History List

    private var historyList: some View {
        List {
            // Resumo
            Section {
                HStack(spacing: 16) {
                    statBubble(
                        count: filteredEntries.filter { $0.action == "on" }.count,
                        label: String(localized: "Turned On"),
                        color: .green,
                        icon: "power"
                    )
                    statBubble(
                        count: filteredEntries.filter { $0.action == "off" }.count,
                        label: String(localized: "Turned Off"),
                        color: .red,
                        icon: "power.circle"
                    )
                    statBubble(
                        count: filteredEntries.count,
                        label: String(localized: "Total"),
                        color: .blue,
                        icon: "number"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

            // Entradas agrupadas por data
            let grouped = groupedEntries
            ForEach(Array(grouped.keys.sorted().reversed()), id: \.self) { date in
                Section(formatDate(date)) {
                    ForEach(grouped[date] ?? []) { entry in
                        HistoryEntryRow(entry: entry)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No actions recorded", comment: "Empty history state title")
                .font(.headline)

            Text("Your change history will appear here.", comment: "Empty history state subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Helpers

    private var filteredEntries: [ToggleHistoryEntry] {
        if let filter = selectedFilter {
            return entries.filter { $0.serviceType == filter.rawValue }
        }
        return entries
    }

    private var groupedEntries: [Date: [ToggleHistoryEntry]] {
        Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }

    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return String(localized: "Today")
        } else if Calendar.current.isDateInYesterday(date) {
            return String(localized: "Yesterday")
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func clearHistory() {
        for entry in entries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }

    private func statBubble(count: Int, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.title3.weight(.bold).monospacedDigit())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Entry Row

struct HistoryEntryRow: View {
    let entry: ToggleHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            // Ícone do serviço
            if let service = entry.service {
                Image(systemName: service.icon)
                    .foregroundStyle(service.activeColor)
                    .frame(width: 24)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.service?.displayName ?? entry.serviceType)
                        .font(.subheadline.weight(.medium))

                    Text(entry.toggleAction?.displayName ?? entry.action)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            entry.action == "on"
                                ? Color.green.opacity(0.15)
                                : Color.red.opacity(0.15),
                            in: Capsule()
                        )
                        .foregroundStyle(entry.action == "on" ? .green : .red)
                }

                HStack(spacing: 4) {
                    if let source = entry.toggleSource {
                        Image(systemName: source.icon)
                        Text(source.displayName)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Hora
            Text(formatTime(entry.timestamp))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityLabel("\(entry.service?.displayName ?? "") \(entry.toggleAction?.displayName ?? "") at \(formatTime(entry.timestamp))")
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
