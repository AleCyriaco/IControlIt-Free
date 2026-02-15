import SwiftUI
import SwiftData

/// Tela principal com os 3 toggles grandes
struct MainToggleView: View {
    @StateObject private var viewModel = ToggleViewModel()
    @StateObject private var batteryService = BatteryMonitorService.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("customShortcuts") private var customShortcutsData: Data = Data()

    private var customShortcuts: [CustomShortcut] {
        (try? JSONDecoder().decode([CustomShortcut].self, from: customShortcutsData)) ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header com bateria
                    batteryHeader

                    // Toggles principais
                    VStack(spacing: 16) {
                        ForEach(RadioServiceType.allCases) { service in
                            ToggleCardView(
                                service: service,
                                status: viewModel.radioService.status(for: service),
                                onToggle: { viewModel.toggleService(service) },
                                onOpenSettings: { viewModel.openSettingsForService(service) }
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Botões de ação rápida
                    quickActionButtons

                    // Sugestão de economia de bateria
                    if viewModel.showBatterySuggestion {
                        batterySuggestionCard
                    }

                    // Atalho limpar histórico
                    clearHistoryButton

                    #if PREMIUM
                    // Atalhos customizados do catálogo
                    if !customShortcuts.isEmpty {
                        customShortcutsSection
                    }
                    #endif

                    // Atalhos rápidos
                    shortcutsSection

                    // Economia estimada
                    savingsEstimateCard
                }
                .padding(.vertical)
            }
            .background(backgroundGradient)
            .navigationTitle("IControlIt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.refresh()
            }
        }
    }

    // MARK: - Battery Header

    private var batteryHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: batteryService.batteryIcon)
                .font(.title2)
                .foregroundStyle(Color(batteryService.batteryColor))

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Battery: \(batteryService.batteryPercentage)%"))
                    .font(.subheadline.weight(.semibold))

                if batteryService.isLowPowerMode {
                    Text("Low Power Mode active", comment: "Battery status label")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Spacer()

            if batteryService.batteryState == .charging {
                Label(String(localized: "Charging"), systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Quick Action Buttons

    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.turnAllOff()
            } label: {
                Label(String(localized: "Turn Off All"), systemImage: "power")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.turnAllOn()
            } label: {
                Label(String(localized: "Turn On All"), systemImage: "bolt.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Battery Suggestion

    private var batterySuggestionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                Text("Low battery", comment: "Battery warning title")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            Text("Turning off non-essential services can save battery.", comment: "Battery warning description")
                .font(.caption)
                .foregroundStyle(.secondary)

            let suggestions = batteryService.suggestedServicesToDisable
            if !suggestions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(suggestions) { service in
                        Button {
                            viewModel.openSettingsForService(service)
                        } label: {
                            Label(service.displayName, systemImage: service.icon)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.orange.opacity(0.15), in: Capsule())
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Clear History Button

    private var clearHistoryButton: some View {
        Button {
            let safariURL = "settings-navigation://com.apple.Settings.Apps/com.apple.mobilesafari#CLEAR_HISTORY_AND_DATA"
            if let url = URL(string: safariURL) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        let safariName = UserDefaults.standard.string(forKey: "shortcutName_safari") ?? "ClearHistoryOnOff"
                        RadioControlService.shared.openViaShortcut(name: safariName, fallbackURL: safariURL)
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Clear Browsing History", comment: "Safari clear history button")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Open Safari in Settings to clear data", comment: "Safari clear history description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
    }

    // MARK: - Custom Shortcuts Section

    private var customShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(.blue)
                Text("My Shortcuts", comment: "Custom shortcuts section title")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            VStack(spacing: 8) {
                ForEach(customShortcuts) { shortcut in
                    Button {
                        if !shortcut.shortcutName.isEmpty {
                            RadioControlService.shared.openViaShortcut(
                                name: shortcut.shortcutName,
                                fallbackURL: shortcut.settingsURL
                            )
                        } else {
                            RadioControlService.shared.openDirectURL(shortcut.settingsURL)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: shortcut.icon)
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .frame(width: 36, height: 36)
                                .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(shortcut.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                if !shortcut.shortcutName.isEmpty {
                                    Text(shortcut.shortcutName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Shortcuts Section

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "command")
                    .foregroundStyle(.blue)
                Text("Quick Shortcuts", comment: "Shortcuts section title")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            Text("Use Siri or the Shortcuts app for quick control:", comment: "Shortcuts section description")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                shortcutRow(
                    phrase: String(localized: "\"Hey Siri, turn off all\""),
                    description: String(localized: "Turns off Wi-Fi, Bluetooth and GPS")
                )
                shortcutRow(
                    phrase: String(localized: "\"Hey Siri, privacy mode\""),
                    description: String(localized: "Applies privacy profile")
                )
                shortcutRow(
                    phrase: String(localized: "\"Hey Siri, save battery\""),
                    description: String(localized: "Turns off non-essential services")
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func shortcutRow(phrase: String, description: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(phrase)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "mic.fill")
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Savings Estimate

    private var savingsEstimateCard: some View {
        let estimate = viewModel.batterySavingsIfAllOff

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("Estimated Savings", comment: "Savings card title")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            HStack(spacing: 16) {
                VStack {
                    Text(estimate.formattedPercent)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    Text("per hour", comment: "Savings unit")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text(estimate.formattedMinutes)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    Text("extra per day", comment: "Savings unit")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)

            Text("* Estimate when turning off all services. Actual values may vary.", comment: "Savings disclaimer")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(.systemBackground), Color(.systemBackground)]
                : [Color(.systemGroupedBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MainToggleView()
}
