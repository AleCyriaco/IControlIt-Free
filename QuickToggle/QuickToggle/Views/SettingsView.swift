import SwiftUI

/// Tela de ajustes do app
struct SettingsView: View {
    @StateObject private var batteryService = BatteryMonitorService.shared
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("lowBatteryAlert") private var lowBatteryAlert = true
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = true
    @State private var showShortcutSetup = false
    @State private var showCatalog = false
    @State private var showAddShortcut = false
    @State private var pendingEntry: SettingsURLEntry?
    @AppStorage("lowBatteryThreshold") private var lowBatteryThreshold = 20.0
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoOpenSettings") private var autoOpenSettings = true
    @AppStorage("shortcutName_wifi") private var shortcutNameWifi = "WiFiOnOff"
    @AppStorage("shortcutName_bluetooth") private var shortcutNameBluetooth = "BluetoothOnOff"
    @AppStorage("shortcutName_location") private var shortcutNameGPS = "LocationOnOff"
    @AppStorage("shortcutName_safari") private var shortcutNameSafari = "ClearHistoryOnOff"
    @AppStorage("customShortcuts") private var customShortcutsData: Data = Data()

    private var customShortcuts: [CustomShortcut] {
        (try? JSONDecoder().decode([CustomShortcut].self, from: customShortcutsData)) ?? []
    }

    private func saveCustomShortcuts(_ shortcuts: [CustomShortcut]) {
        customShortcutsData = (try? JSONEncoder().encode(shortcuts)) ?? Data()
    }

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
                    Text("Abre via Apple Shortcuts. Configure os atalhos em Setup Atalhos.")
                }

                // Mais atalhos (customizáveis pelo usuário)
                Section {
                    ForEach(customShortcuts) { shortcut in
                        Button {
                            RadioControlService.shared.openViaShortcut(
                                name: shortcut.shortcutName,
                                fallbackURL: shortcut.settingsURL
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: shortcut.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(shortcut.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(shortcut.shortcutName)
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
                    .onDelete { indexSet in
                        var shortcuts = customShortcuts
                        shortcuts.remove(atOffsets: indexSet)
                        saveCustomShortcuts(shortcuts)
                    }

                    // Botão adicionar do catálogo
                    Button {
                        showCatalog = true
                    } label: {
                        Label(String(localized: "Adicionar do Catálogo"), systemImage: "plus.circle")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Mais Atalhos")
                } footer: {
                    Text("Adicione atalhos do catálogo e vincule a um Shortcut da Apple. Deslize para remover.")
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
                            Text(String(format: String(localized: "Alertar quando bateria atingir %d%%"), Int(lowBatteryThreshold)))
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

                // Nomes dos Atalhos (renomear para casar com Shortcuts do usuário)
                Section {
                    shortcutNameRow(label: "Wi-Fi", binding: $shortcutNameWifi)
                    shortcutNameRow(label: "Bluetooth", binding: $shortcutNameBluetooth)
                    shortcutNameRow(label: "GPS", binding: $shortcutNameGPS)
                    shortcutNameRow(label: "Safari", binding: $shortcutNameSafari)
                } header: {
                    Text("Nomes dos Atalhos")
                } footer: {
                    Text("Os nomes devem corresponder exatamente aos atalhos criados no app Atalhos da Apple.")
                }

                // Configurar Atalhos
                Section {
                    Button {
                        showShortcutSetup = true
                    } label: {
                        Label("Configurar Atalhos", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Configurar Deep Links")
                } footer: {
                    Text("Crie atalhos no app Atalhos da Apple com a ação \"Abrir URL\" para acessar seções dos Ajustes.")
                }

                // Sobre
                Section("Sobre") {
                    Button {
                        if let url = URL(string: "https://virttus.com") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Versão 1.0.0")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("Build by virttus.com")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }

                    NavigationLink {
                        LimitationsView()
                    } label: {
                        Label("Limitações conhecidas", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Ajustes")
            .sheet(isPresented: $showShortcutSetup) {
                ShortcutSetupView()
            }
            .sheet(isPresented: $showCatalog) {
                SettingsURLCatalogView { entry in
                    pendingEntry = entry
                    showCatalog = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAddShortcut = true
                    }
                }
            }
            .sheet(isPresented: $showAddShortcut) {
                if let entry = pendingEntry {
                    AddCustomShortcutView(entry: entry) { newShortcut in
                        var shortcuts = customShortcuts
                        shortcuts.append(newShortcut)
                        saveCustomShortcuts(shortcuts)
                        showAddShortcut = false
                        pendingEntry = nil
                    }
                }
            }
        }
    }

    // MARK: - Settings Shortcut Row

    private func settingsShortcut(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        service: RadioServiceType?,
        shortcutStorageKey: String? = nil,
        defaultShortcutName: String? = nil
    ) -> some View {
        Button {
            if let service = service {
                RadioControlService.shared.openSettings(for: service)
            } else if let storageKey = shortcutStorageKey, let defaultName = defaultShortcutName {
                let name = UserDefaults.standard.string(forKey: storageKey) ?? defaultName
                RadioControlService.shared.openViaShortcut(name: name, fallbackURL: "")
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

    // MARK: - Shortcut Name Row

    private func shortcutNameRow(label: String, binding: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, text: binding)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.blue)
                .frame(maxWidth: 150)
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
