import SwiftUI
import SwiftData

/// Tela principal com os 3 toggles grandes
struct MainToggleView: View {
    @StateObject private var viewModel = ToggleViewModel()
    @StateObject private var batteryService = BatteryMonitorService.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

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

                    // Atalhos rápidos
                    shortcutsSection

                    // Economia estimada
                    savingsEstimateCard
                }
                .padding(.vertical)
            }
            .background(backgroundGradient)
            .navigationTitle("QuickToggle")
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
                Text("\(String(localized: "Bateria")): \(batteryService.batteryPercentage)%")
                    .font(.subheadline.weight(.semibold))

                if batteryService.isLowPowerMode {
                    Text("Modo Economia ativo")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Spacer()

            if batteryService.batteryState == .charging {
                Label("Carregando", systemImage: "bolt.fill")
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
                Label("Desligar Tudo", systemImage: "power")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.turnAllOn()
            } label: {
                Label("Ligar Tudo", systemImage: "bolt.fill")
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
                Text("Bateria baixa")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            Text("Desligar serviços não essenciais pode economizar bateria.")
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
            let safariName = UserDefaults.standard.string(forKey: "shortcutName_safari") ?? "Safari"
            RadioControlService.shared.openViaShortcut(name: safariName, fallbackURL: "settings-navigation://com.apple.Settings.Apps/com.apple.mobilesafari")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Limpar Histórico de Internet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Abrir Safari nos Ajustes para limpar dados")
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

    // MARK: - Shortcuts Section

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "command")
                    .foregroundStyle(.blue)
                Text("Atalhos Rápidos")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            Text("Use Siri ou o app Atalhos para controlar rapidamente:")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                shortcutRow(
                    phrase: "\"Hey Siri, desliga tudo\"",
                    description: "Desliga Wi-Fi, Bluetooth e GPS"
                )
                shortcutRow(
                    phrase: "\"Hey Siri, modo privacidade\"",
                    description: "Aplica perfil de privacidade"
                )
                shortcutRow(
                    phrase: "\"Hey Siri, economia de bateria\"",
                    description: "Desliga serviços não essenciais"
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
                Text("Economia Estimada")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            HStack(spacing: 16) {
                VStack {
                    Text(estimate.formattedPercent)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    Text("por hora")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text(estimate.formattedMinutes)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    Text("extra por dia")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)

            Text("* Estimativa ao desligar todos os serviços. Valores reais podem variar.")
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
