import SwiftUI
import UIKit

/// Tela de configuração para instalar Apple Shortcuts automaticamente via import URL
struct ShortcutSetupView: View {
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = false
    @Environment(\.dismiss) private var dismiss
    @State private var installedName: String?

    /// Base URL dos arquivos .shortcut hospedados no GitHub
    private let baseURL = "https://raw.githubusercontent.com/AleCyriaco/QuickToggle/main/QuickToggle/QuickToggle"

    private let shortcuts: [(name: String, fileName: String, icon: String, color: Color, description: String)] = [
        ("WiFi", "WiFi", "wifi", .green, String(localized: "Wi-Fi nos Ajustes")),
        ("Bluetooth", "Bluetooth", "dot.radiowaves.left.and.right", .blue, String(localized: "Bluetooth nos Ajustes")),
        ("GPS", "GPS", "location.fill", .red, String(localized: "Localização nos Ajustes")),
        ("Safari", "Safari", "safari", .blue, String(localized: "Limpar histórico Safari")),
        ("Bateria", "Bateria", "battery.100percent", .green, String(localized: "Saúde da bateria")),
        ("DadosCelulares", "DadosCelulares", "antenna.radiowaves.left.and.right", .teal, String(localized: "Dados móveis")),
        ("Foco", "Foco", "moon.fill", .indigo, String(localized: "Não Perturbe")),
        ("Notificacoes", "Notificacoes", "bell.badge.fill", .red, String(localized: "Notificações")),
        ("TelaeBrilho", "TelaeBrilho", "sun.max.fill", .orange, "Display & Brightness"),
        ("VPN", "VPN", "lock.shield.fill", .purple, "VPN"),
        ("Armazenamento", "Armazenamento", "internaldrive.fill", .gray, String(localized: "Armazenamento")),
        ("Senhas", "Senhas", "key.fill", .gray, String(localized: "Senhas")),
    ]

    var body: some View {
        NavigationStack {
            List {
                // Instruções
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "Como funciona"), systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 8) {
                            stepRow(number: "1", text: String(localized: "step_1_auto"))
                            stepRow(number: "2", text: String(localized: "step_2_auto"))
                            stepRow(number: "3", text: String(localized: "step_3_auto"))
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Essenciais
                Section(String(localized: "Essenciais")) {
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

                // Instalar todos
                Section {
                    Button {
                        installAll()
                    } label: {
                        Label(String(localized: "Instalar Todos"), systemImage: "square.and.arrow.down.on.square")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }

                Section {
                    Button {
                        shortcutsInstalled = true
                        dismiss()
                    } label: {
                        Text(String(localized: "Concluir"))
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle(String(localized: "Setup Atalhos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Pular")) {
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

    private func shortcutRow(_ shortcut: (name: String, fileName: String, icon: String, color: Color, description: String)) -> some View {
        HStack(spacing: 12) {
            Image(systemName: shortcut.icon)
                .foregroundStyle(shortcut.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(shortcut.name)
                        .font(.body.weight(.medium))
                    if installedName == shortcut.name {
                        Text(String(localized: "Instalado!"))
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
                installShortcut(shortcut)
            } label: {
                Label(String(localized: "Instalar"), systemImage: "square.and.arrow.down")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.blue, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
    }

    private func installShortcut(_ shortcut: (name: String, fileName: String, icon: String, color: Color, description: String)) {
        let fileURL = "\(baseURL)/\(shortcut.fileName).shortcut"
        guard let encodedURL = fileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedName = shortcut.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        let importURLString = "shortcuts://import-shortcut/?url=\(encodedURL)&name=\(encodedName)"

        if let url = URL(string: importURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        // Salvar nome do atalho no UserDefaults
        let storageKey: String
        switch shortcut.name {
        case "WiFi": storageKey = "shortcutName_wifi"
        case "Bluetooth": storageKey = "shortcutName_bluetooth"
        case "GPS": storageKey = "shortcutName_location"
        default: storageKey = "shortcutName_\(shortcut.fileName.lowercased())"
        }
        UserDefaults.standard.set(shortcut.name, forKey: storageKey)

        withAnimation {
            installedName = shortcut.name
        }
    }

    private func installAll() {
        // Instalar o primeiro, depois os demais com delay
        for (index, shortcut) in shortcuts.prefix(4).enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                installShortcut(shortcut)
            }
        }
    }
}

#Preview {
    ShortcutSetupView()
}
