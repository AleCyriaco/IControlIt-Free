import SwiftUI
import UIKit

/// Tela de configuração para instalar Apple Shortcuts via arquivos .shortcut
struct ShortcutSetupView: View {
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = false
    @Environment(\.dismiss) private var dismiss
    @State private var installedName: String?
    @State private var errorMessage: String?

    private let shortcuts: [(name: String, url: String, icon: String, color: Color, description: String)] = [
        ("GPS", "settings-navigation://com.apple.Settings.PrivacyAndSecurity/LOCATION", "location.fill", .red, String(localized: "Localização nos Ajustes")),
        ("WiFi", "settings-navigation://com.apple.Settings.WiFi", "wifi", .green, String(localized: "Wi-Fi nos Ajustes")),
        ("Bluetooth", "settings-navigation://com.apple.Settings.Bluetooth", "dot.radiowaves.left.and.right", .blue, String(localized: "Bluetooth nos Ajustes")),
        ("Safari", "settings-navigation://com.apple.Settings.Apps/com.apple.mobilesafari#CLEAR_HISTORY_AND_DATA", "safari", .blue, String(localized: "Limpar histórico Safari")),
        ("Bateria", "settings-navigation://com.apple.Settings.Battery", "battery.100percent", .green, String(localized: "Saúde da bateria")),
        ("DadosCelulares", "settings-navigation://com.apple.Settings.Cellular", "antenna.radiowaves.left.and.right", .teal, String(localized: "Dados móveis")),
        ("Foco", "settings-navigation://com.apple.Settings.Focus", "moon.fill", .indigo, String(localized: "Não Perturbe")),
        ("Notificacoes", "settings-navigation://com.apple.Settings.Notifications", "bell.badge.fill", .red, String(localized: "Notificações")),
        ("TelaeBrilho", "settings-navigation://com.apple.Settings.Display", "sun.max.fill", .orange, "Display & Brightness"),
        ("VPN", "settings-navigation://com.apple.Settings#com.apple.Settings.VPN", "lock.shield.fill", .purple, "VPN"),
        ("Armazenamento", "settings-navigation://com.apple.Settings.General/STORAGE_MGMT", "internaldrive.fill", .gray, String(localized: "Armazenamento")),
        ("Senhas", "settings-navigation://com.apple.Settings.Apps/com.apple.Passwords", "key.fill", .gray, String(localized: "Senhas")),
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
                            stepRow(number: "1", text: String(localized: "step_1_install"))
                            stepRow(number: "2", text: String(localized: "step_2_install"))
                            stepRow(number: "3", text: String(localized: "step_3_install"))
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
            .alert("Erro", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
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
                installShortcut(name: shortcut.name)
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

    private func installShortcut(name: String) {
        // Buscar o arquivo .shortcut no bundle
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: "shortcut") else {
            errorMessage = String(localized: "Arquivo não encontrado: \(name).shortcut")
            return
        }

        // Copiar para pasta temporária para garantir acesso
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("\(name).shortcut")

        try? FileManager.default.removeItem(at: tempURL)
        do {
            try FileManager.default.copyItem(at: fileURL, to: tempURL)
        } catch {
            errorMessage = String(localized: "Erro ao preparar arquivo")
            return
        }

        // Usar UIDocumentInteractionController para abrir no Shortcuts
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }

            // Encontrar o VC mais ao topo
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            let controller = UIDocumentInteractionController(url: tempURL)
            controller.uti = "com.apple.shortcuts.workflow"
            controller.name = "\(name).shortcut"

            if !controller.presentOpenInMenu(from: .zero, in: topVC.view, animated: true) {
                // Fallback: tentar presentPreview
                if !controller.presentPreview(animated: true) {
                    // Último fallback: abrir via share sheet
                    let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                    topVC.present(activityVC, animated: true)
                }
            }

            withAnimation {
                installedName = name
            }
        }
    }
}

#Preview {
    ShortcutSetupView()
}
