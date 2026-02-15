import SwiftUI

/// Tela de ajustes do app
struct SettingsView: View {
    @StateObject private var batteryService = BatteryMonitorService.shared
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("lowBatteryAlert") private var lowBatteryAlert = true
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = true
    @State private var showShortcutSetup = false
    @State private var showCatalog = false
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
                        subtitle: String(localized: "Open Wi-Fi settings"),
                        icon: "wifi",
                        color: .green,
                        service: .wifi
                    )
                    settingsShortcut(
                        title: "Bluetooth",
                        subtitle: String(localized: "Open Bluetooth settings"),
                        icon: "dot.radiowaves.left.and.right",
                        color: .blue,
                        service: .bluetooth
                    )
                    settingsShortcut(
                        title: String(localized: "Location"),
                        subtitle: String(localized: "Open Privacy settings"),
                        icon: "location.fill",
                        color: .red,
                        service: .location
                    )
                } header: {
                    Text("Quick Shortcuts", comment: "Section header for quick shortcuts")
                } footer: {
                    Text("Opens via Apple Shortcuts. Configure shortcuts in Shortcut Setup.", comment: "Footer explaining shortcuts")
                }

                #if PREMIUM
                // Mais atalhos (customizáveis pelo usuário)
                Section {
                    ForEach(customShortcuts) { shortcut in
                        Button {
                            executeCustomShortcut(shortcut)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: shortcut.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(shortcut.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    if !shortcut.shortcutName.isEmpty {
                                        Text(String(localized: "Shortcut: \(shortcut.shortcutName)"))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text(String(localized: "Opens via direct URL"))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
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
                        Label(String(localized: "Add from Catalog"), systemImage: "plus.circle")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("More Shortcuts", comment: "Section header for custom shortcuts")
                } footer: {
                    Text("Add shortcuts from the catalog and link to an Apple Shortcut. Swipe to remove.", comment: "Footer for custom shortcuts section")
                }
                #else
                // Teaser para versão Full
                Section {
                    Button {
                        openFullVersionOnAppStore()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add from Catalog", comment: "Teaser button for catalog")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("Available in IControlIt Full", comment: "Teaser subtitle pointing to full version")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }

                            Spacer()

                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("More Shortcuts", comment: "Section header")
                } footer: {
                    Text("Custom shortcuts from the Settings catalog are available in IControlIt Full.", comment: "Teaser footer for full version")
                }
                #endif

                // Economia de bateria
                Section(String(localized: "Battery Saving")) {
                    Toggle(isOn: $lowBatteryAlert) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Low battery alert", comment: "Toggle label")
                                Text("Suggests turning off services when battery is low", comment: "Toggle description")
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
                            Text(String(localized: "Alert when battery reaches \(Int(lowBatteryThreshold))%"))
                                .font(.subheadline)

                            Slider(value: $lowBatteryThreshold, in: 5...50, step: 5) {
                                Text("Threshold", comment: "Slider label")
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
                            Text("Saving details", comment: "Navigation link to battery saving details")
                        } icon: {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }

                // Comportamento
                Section(String(localized: "Behavior")) {
                    Toggle(isOn: $hapticFeedback) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Haptic feedback", comment: "Toggle label")
                                Text("Vibrate when tapping controls", comment: "Toggle description")
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
                                Text("Open Settings automatically", comment: "Toggle label")
                                Text("Redirect to Settings when tapping toggles", comment: "Toggle description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.right.square")
                        }
                    }
                }

                // Notificações
                Section(String(localized: "Notifications")) {
                    HStack {
                        Label("Status", systemImage: "bell.fill")
                        Spacer()
                        Text(notificationService.isAuthorized
                             ? String(localized: "Enabled")
                             : String(localized: "Disabled"))
                            .foregroundStyle(notificationService.isAuthorized ? .green : .red)
                    }

                    if !notificationService.isAuthorized {
                        Button {
                            notificationService.requestPermission()
                        } label: {
                            Label(String(localized: "Allow notifications"), systemImage: "bell.badge")
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
                                Text("Open Shortcuts app", comment: "Button label")
                                    .foregroundStyle(.primary)
                                Text("Create advanced automations with Siri", comment: "Button description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "command")
                                .foregroundStyle(.blue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Siri commands:", comment: "Siri commands header")
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
                            Text("\"Hey Siri, Turn Off All\"", comment: "Siri command example")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Siri & Shortcuts", comment: "Section header")
                }

                // Nomes dos Atalhos
                Section {
                    shortcutNameRow(label: "Wi-Fi", binding: $shortcutNameWifi)
                    shortcutNameRow(label: "Bluetooth", binding: $shortcutNameBluetooth)
                    shortcutNameRow(label: "GPS", binding: $shortcutNameGPS)
                    shortcutNameRow(label: "Safari", binding: $shortcutNameSafari)
                } header: {
                    Text("Shortcut Names", comment: "Section header")
                } footer: {
                    Text("Names must match exactly the shortcuts created in the Apple Shortcuts app.", comment: "Section footer")
                }

                // Configurar Atalhos
                Section {
                    Button {
                        showShortcutSetup = true
                    } label: {
                        Label(String(localized: "Configure Shortcuts"), systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Configure Deep Links", comment: "Section header")
                } footer: {
                    Text("Create shortcuts in the Apple Shortcuts app with the \"Open URL\" action to access Settings sections.", comment: "Section footer")
                }

                // Sobre
                Section(String(localized: "About")) {
                    Button {
                        if let url = URL(string: "https://virttus.com") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text(String(localized: "Version 1.0.0"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("Built by virttus.com")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }

                    NavigationLink {
                        LimitationsView()
                    } label: {
                        Label(String(localized: "Known limitations"), systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .sheet(isPresented: $showShortcutSetup) {
                ShortcutSetupView()
            }
            #if PREMIUM
            .sheet(isPresented: $showCatalog) {
                SettingsURLCatalogView { newShortcut in
                    var shortcuts = customShortcuts
                    shortcuts.append(newShortcut)
                    saveCustomShortcuts(shortcuts)
                }
            }
            #endif
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

    /// Executa um custom shortcut: se tem nome de shortcut, roda via Atalhos; senão, abre URL direta
    private func executeCustomShortcut(_ shortcut: CustomShortcut) {
        if !shortcut.shortcutName.isEmpty {
            RadioControlService.shared.openViaShortcut(
                name: shortcut.shortcutName,
                fallbackURL: shortcut.settingsURL
            )
        } else {
            RadioControlService.shared.openDirectURL(shortcut.settingsURL)
        }
    }

    private func openShortcutsApp() {
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }

    private func openFullVersionOnAppStore() {
        // TODO: Replace with actual App Store URL after publishing
        if let url = URL(string: "https://apps.apple.com/app/icontrolit/id0000000000") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Limitations View

struct LimitationsView: View {
    var body: some View {
        List {
            Section(String(localized: "Radio Control on iOS")) {
                limitationRow(
                    title: "Wi-Fi",
                    limitation: String(localized: "Apps cannot turn off Wi-Fi directly. iOS only allows using NEHotspotConfiguration to configure specific networks."),
                    workaround: String(localized: "We open iOS Settings. On iOS 17-25, it went directly to Wi-Fi. On iOS 26+, it opens the main page.")
                )

                limitationRow(
                    title: "Bluetooth",
                    limitation: String(localized: "CoreBluetooth can detect the state but cannot turn it on/off globally."),
                    workaround: String(localized: "We open iOS Settings. On iOS 17-25, it went directly to Bluetooth. On iOS 26+, it opens the main page.")
                )

                limitationRow(
                    title: String(localized: "Location / GPS"),
                    limitation: String(localized: "CLLocationManager only controls the app's own permission, not global GPS."),
                    workaround: String(localized: "We open iOS Settings. On iOS 17-25, it went directly to Privacy > Location. On iOS 26+, it opens the main page.")
                )
            }

            Section("URL Schemes & iOS 26") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Starting with iOS 26, Apple removed the ability to deep link to specific Settings sections via URL Schemes (App-prefs:root=WIFI, etc).", comment: "iOS 26 limitation")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("The app opens iOS Settings, but navigating to Wi-Fi/Bluetooth/Location requires manual taps from the user.", comment: "iOS 26 limitation detail")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("The best alternative on iOS 26 is using Shortcuts and Siri to create automations.", comment: "iOS 26 recommendation")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }

            Section(String(localized: "Best Approach")) {
                VStack(alignment: .leading, spacing: 8) {
                    approachRow(
                        number: "1",
                        title: String(localized: "URL Schemes for Settings"),
                        description: String(localized: "Redirects to the exact panel with minimum taps")
                    )
                    approachRow(
                        number: "2",
                        title: String(localized: "Shortcuts/Automations"),
                        description: String(localized: "App Intents allows creating actions in the Shortcuts app")
                    )
                    approachRow(
                        number: "3",
                        title: String(localized: "Interactive Widget"),
                        description: String(localized: "Quick access from the home screen without opening the app")
                    )
                    approachRow(
                        number: "4",
                        title: String(localized: "Scheduled Notifications"),
                        description: String(localized: "Reminders to change services at specific times")
                    )
                }
                .padding(.vertical, 4)
            }

            Section("App Store") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This app does not use private APIs and follows the App Store Review Guidelines.", comment: "App Store compliance note")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(String(localized: "Limitations"))
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
