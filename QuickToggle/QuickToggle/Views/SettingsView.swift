import SwiftUI

/// Tela de ajustes do app
struct SettingsView: View {
    @StateObject private var batteryService = BatteryMonitorService.shared
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("lowBatteryAlert") private var lowBatteryAlert = true
    @AppStorage("lowBatteryThreshold") private var lowBatteryThreshold = 20.0
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoOpenSettings") private var autoOpenSettings = true

    var body: some View {
        NavigationStack {
            List {
                // Atalhos rápidos para rádios do iOS
                Section {
                    settingsShortcut(
                        title: "Wi-Fi",
                        subtitle: "Abrir ajustes de Wi-Fi",
                        icon: "wifi",
                        color: .green,
                        service: .wifi
                    )
                    settingsShortcut(
                        title: "Bluetooth",
                        subtitle: "Abrir ajustes de Bluetooth",
                        icon: "dot.radiowaves.left.and.right",
                        color: .blue,
                        service: .bluetooth
                    )
                    settingsShortcut(
                        title: "Localização",
                        subtitle: "Abrir ajustes de Privacidade",
                        icon: "location.fill",
                        color: .red,
                        service: .location
                    )
                } header: {
                    Text("Atalhos Rápidos")
                } footer: {
                    Text("Acesse diretamente a seção exata nos Ajustes do iOS para cada serviço.")
                }

                // Mais atalhos para seções dos Ajustes do iOS
                Section {
                    settingsShortcut(
                        title: "Limpar Safari",
                        subtitle: "Limpar histórico e dados do Safari",
                        icon: "safari",
                        color: .blue,
                        service: nil,
                        customURL: "App-prefs:SAFARI&path=CLEAR_HISTORY_AND_DATA"
                    )
                    settingsShortcut(
                        title: "Bateria",
                        subtitle: "Saúde e uso da bateria",
                        icon: "battery.100percent",
                        color: .green,
                        service: nil,
                        customURL: "App-prefs:BATTERY_USAGE"
                    )
                    settingsShortcut(
                        title: "Dados Celulares",
                        subtitle: "Configurações de dados móveis",
                        icon: "antenna.radiowaves.left.and.right",
                        color: Color.teal,
                        service: nil,
                        customURL: "App-prefs:MOBILE_DATA_SETTINGS_ID"
                    )
                    settingsShortcut(
                        title: "Foco",
                        subtitle: "Modo Não Perturbe e Focus",
                        icon: "moon.fill",
                        color: .indigo,
                        service: nil,
                        customURL: "App-prefs:DO_NOT_DISTURB"
                    )
                    settingsShortcut(
                        title: "Notificações",
                        subtitle: "Gerenciar notificações de apps",
                        icon: "bell.badge.fill",
                        color: .red,
                        service: nil,
                        customURL: "App-prefs:NOTIFICATIONS_ID"
                    )
                    settingsShortcut(
                        title: "Tela e Brilho",
                        subtitle: "Brilho, Night Shift, Auto-Lock",
                        icon: "sun.max.fill",
                        color: .orange,
                        service: nil,
                        customURL: "App-prefs:DISPLAY"
                    )
                    settingsShortcut(
                        title: "Sons e Hápticos",
                        subtitle: "Volume, toques e vibrações",
                        icon: "speaker.wave.3.fill",
                        color: .pink,
                        service: nil,
                        customURL: "App-prefs:Sounds"
                    )
                    settingsShortcut(
                        title: "VPN",
                        subtitle: "Configurações de VPN",
                        icon: "lock.shield.fill",
                        color: .purple,
                        service: nil,
                        customURL: "App-prefs:VPN"
                    )
                    settingsShortcut(
                        title: "Armazenamento",
                        subtitle: "Espaço do iPhone",
                        icon: "internaldrive.fill",
                        color: .gray,
                        service: nil,
                        customURL: "App-prefs:General&path=STORAGE_MGMT"
                    )
                    settingsShortcut(
                        title: "Senhas",
                        subtitle: "Senhas salvas e preenchimento",
                        icon: "key.fill",
                        color: .gray,
                        service: nil,
                        customURL: "App-prefs:PASSWORDS"
                    )
                    settingsShortcut(
                        title: "Ajustes gerais",
                        subtitle: "Abrir Ajustes do iOS",
                        icon: "gear",
                        color: .gray,
                        service: nil
                    )
                } header: {
                    Text("Mais Atalhos")
                } footer: {
                    Text("Atalhos para seções específicas dos Ajustes do iOS. No iOS 26+, alguns podem abrir na página principal.")
                }

                // Economia de bateria
                Section("Economia de Bateria") {
                    Toggle(isOn: $lowBatteryAlert) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Alerta de bateria baixa")
                                Text("Sugere desligar serviços quando a bateria estiver baixa")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "battery.25percent")
                                .foregroundStyle(.orange)
                        }
                    }

                    if lowBatteryAlert {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alertar quando bateria atingir \(Int(lowBatteryThreshold))%")
                                .font(.subheadline)

                            Slider(value: $lowBatteryThreshold, in: 5...50, step: 5) {
                                Text("Limite")
                            } minimumValueLabel: {
                                Text("5%")
                                    .font(.caption2)
                            } maximumValueLabel: {
                                Text("50%")
                                    .font(.caption2)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    NavigationLink {
                        BatterySavingView()
                    } label: {
                        Label {
                            Text("Detalhes de economia")
                        } icon: {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }

                // Comportamento
                Section("Comportamento") {
                    Toggle(isOn: $hapticFeedback) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Feedback háptico")
                                Text("Vibração ao tocar nos controles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "hand.tap.fill")
                        }
                    }

                    Toggle(isOn: $autoOpenSettings) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Abrir Ajustes automaticamente")
                                Text("Redirecionar aos Ajustes ao tocar nos toggles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.right.square")
                        }
                    }
                }

                // Notificações
                Section("Notificações") {
                    HStack {
                        Label("Status", systemImage: "bell.fill")
                        Spacer()
                        Text(notificationService.isAuthorized ? "Ativadas" : "Desativadas")
                            .foregroundStyle(notificationService.isAuthorized ? .green : .red)
                    }

                    if !notificationService.isAuthorized {
                        Button {
                            notificationService.requestPermission()
                        } label: {
                            Label("Permitir notificações", systemImage: "bell.badge")
                        }
                    }
                }

                // Atalhos/Shortcuts
                Section {
                    Button {
                        openShortcutsApp()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Abrir app Atalhos")
                                    .foregroundStyle(.primary)
                                Text("Crie automações avançadas com Siri")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "command")
                                .foregroundStyle(.blue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comandos de Siri disponíveis:")
                            .font(.subheadline.weight(.medium))

                        ForEach(RadioServiceType.allCases) { service in
                            HStack(spacing: 8) {
                                Image(systemName: "mic.fill")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                Text("\"Hey Siri, \(service.shortcutPhrase)\"")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Text("\"Hey Siri, Desligar Tudo\"")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Siri e Atalhos")
                }

                // Sobre
                Section("Sobre") {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        LimitationsView()
                    } label: {
                        Label("Limitações conhecidas", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }

    // MARK: - Settings Shortcut Row

    private func settingsShortcut(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        service: RadioServiceType?,
        customURL: String? = nil
    ) -> some View {
        Button {
            if let customURL = customURL, let url = URL(string: customURL) {
                UIApplication.shared.open(url)
            } else if let service = service {
                RadioControlService.shared.openSettings(for: service)
            } else {
                RadioControlService.shared.openSettingsFallback()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }

    private func openShortcutsApp() {
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Limitations View

struct LimitationsView: View {
    var body: some View {
        List {
            Section("Controle de Rádios no iOS") {
                limitationRow(
                    title: "Wi-Fi",
                    limitation: "Apps não podem desligar Wi-Fi diretamente. O iOS permite apenas usar NEHotspotConfiguration para configurar redes específicas.",
                    workaround: "Abrimos os Ajustes do iOS. Em iOS 17-25, ia direto para Wi-Fi. No iOS 26+, abre na página principal."
                )

                limitationRow(
                    title: "Bluetooth",
                    limitation: "CoreBluetooth permite detectar o estado, mas não ligar/desligar globalmente.",
                    workaround: "Abrimos os Ajustes do iOS. Em iOS 17-25, ia direto para Bluetooth. No iOS 26+, abre na página principal."
                )

                limitationRow(
                    title: "Localização / GPS",
                    limitation: "CLLocationManager controla apenas a permissão do próprio app, não o GPS global.",
                    workaround: "Abrimos os Ajustes do iOS. Em iOS 17-25, ia direto para Privacidade > Localização. No iOS 26+, abre na página principal."
                )
            }

            Section("URL Schemes e iOS 26") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("A partir do iOS 26, a Apple removeu a possibilidade de deep linking para seções específicas dos Ajustes via URL Schemes (App-prefs:root=WIFI, etc).")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("O app abre os Ajustes do iOS, mas navegar até Wi-Fi/Bluetooth/Localização requer toques manuais do usuário.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("A melhor alternativa no iOS 26 é usar Shortcuts (Atalhos) e Siri para criar automações.")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }

            Section("Melhor Abordagem") {
                VStack(alignment: .leading, spacing: 8) {
                    approachRow(
                        number: "1",
                        title: "URL Schemes para Ajustes",
                        description: "Redireciona ao painel exato com mínimo de toques"
                    )
                    approachRow(
                        number: "2",
                        title: "Shortcuts/Automações",
                        description: "App Intents permite criar ações no app Atalhos"
                    )
                    approachRow(
                        number: "3",
                        title: "Widget Interativo",
                        description: "Acesso rápido pela tela inicial sem abrir o app"
                    )
                    approachRow(
                        number: "4",
                        title: "Notificações Agendadas",
                        description: "Lembretes para alterar serviços em horários específicos"
                    )
                }
                .padding(.vertical, 4)
            }

            Section("App Store") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Este app não usa APIs privadas e segue as App Store Review Guidelines. O uso de App-prefs: é uma área cinza - a Apple pode aceitar ou rejeitar dependendo da revisão.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Limitações")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func limitationRow(title: String, limitation: String, workaround: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(limitation)
                        .font(.caption)
                } icon: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Label {
                    Text(workaround)
                        .font(.caption)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func approachRow(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption.weight(.bold))
                .frame(width: 20, height: 20)
                .background(.blue.opacity(0.15), in: Circle())
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
