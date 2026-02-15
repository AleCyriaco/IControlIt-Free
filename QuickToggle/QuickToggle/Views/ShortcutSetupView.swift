import SwiftUI
import UIKit

/// Tela de configuração para criar os Apple Shortcuts necessários para deep linking
struct ShortcutSetupView: View {
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = false
    @Environment(\.dismiss) private var dismiss
    @State private var copiedName: String?

    private let shortcuts: [(name: String, url: String, icon: String, color: Color, description: String)] = [
        ("GPS", "prefs:root=Privacy&path=LOCATION", "location.fill", .red, "Localização nos Ajustes"),
        ("WiFi", "prefs:root=WIFI", "wifi", .green, "Wi-Fi nos Ajustes"),
        ("Bluetooth", "prefs:root=Bluetooth", "dot.radiowaves.left.and.right", .blue, "Bluetooth nos Ajustes"),
        ("Safari", "prefs:roo=SAFARI&path=CLEAR_HISTORY_AND_DATA", "safari", .blue, "Limpar histórico Safari"),
        ("Bateria", "prefs:root=BATTERY_USAGE", "battery.100percent", .green, "Saúde da bateria"),
        ("DadosCelulares", "prefs:root=MOBILE_DATA_SETTINGS_ID", "antenna.radiowaves.left.and.right", .teal, "Dados móveis"),
        ("Foco", "prefs:root=DO_NOT_DISTURB", "moon.fill", .indigo, "Não Perturbe"),
        ("Notificacoes", "prefs:root=NOTIFICATIONS_ID", "bell.badge.fill", .red, "Notificações"),
        ("TelaeBrilho", "prefs:root=DISPLAY", "sun.max.fill", .orange, "Tela e Brilho"),
        ("VPN", "prefs:root=VPN", "lock.shield.fill", .purple, "VPN"),
        ("Armazenamento", "prefs:root=General&path=STORAGE_MGMT", "internaldrive.fill", .gray, "Armazenamento"),
        ("Senhas", "prefs:root=PASSWORDS", "key.fill", .gray, "Senhas"),
    ]

    var body: some View {
        NavigationStack {
            List {
                // Instruções
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Como funciona", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 8) {
                            stepRow(number: "1", text: String(localized: "step_1"))
                            stepRow(number: "2", text: String(localized: "step_2"))
                            stepRow(number: "3", text: String(localized: "step_3"))
                            stepRow(number: "4", text: String(localized: "step_4"))
                            stepRow(number: "5", text: String(localized: "step_5"))
                            stepRow(number: "6", text: String(localized: "step_6"))
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Essenciais
                Section("Essenciais") {
                    ForEach(shortcuts.prefix(4), id: \.name) { shortcut in
                        shortcutRow(shortcut)
                    }
                }

                // Extras
                Section("Extras") {
                    ForEach(shortcuts.dropFirst(4), id: \.name) { shortcut in
                        shortcutRow(shortcut)
                    }
                }

                Section {
                    Button {
                        shortcutsInstalled = true
                        dismiss()
                    } label: {
                        Text("Concluir")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Setup Atalhos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Pular") {
                        shortcutsInstalled = true
                        dismiss()
                    }
                }
            }
        }
    }

    private func stepRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .frame(width: 20, height: 20)
                .background(.blue.opacity(0.15), in: Circle())
                .foregroundStyle(.blue)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func shortcutRow(_ shortcut: (name: String, url: String, icon: String, color: Color, description: String)) -> some View {
        HStack(spacing: 12) {
            Image(systemName: shortcut.icon)
                .foregroundStyle(shortcut.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(shortcut.name)
                        .font(.body.weight(.medium))
                    if copiedName == shortcut.name {
                        Text("Copiado!")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
                Text(shortcut.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                copyAndOpenShortcuts(name: shortcut.name, url: shortcut.url)
            } label: {
                Label("Copiar e Criar", systemImage: "doc.on.clipboard")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.blue, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
    }

    private func copyAndOpenShortcuts(name: String, url: String) {
        // Copia a URL pro clipboard
        UIPasteboard.general.string = url

        // Feedback visual
        withAnimation {
            copiedName = name
        }

        // Abre o app Atalhos para criar novo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let shortcutsURL = URL(string: "shortcuts://create-shortcut") {
                UIApplication.shared.open(shortcutsURL)
            }
        }
    }
}

#Preview {
    ShortcutSetupView()
}
