import SwiftUI
import UIKit

/// Tela de configuração para instalar Apple Shortcuts via iCloud links
struct ShortcutSetupView: View {
    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = false
    @Environment(\.dismiss) private var dismiss
    @State private var installedName: String?

    /// iCloud shortcut sharing links - abrem direto no app Atalhos para adicionar
    private let shortcuts: [(name: String, iCloudURL: String, icon: String, color: Color, description: String)] = [
        ("WiFiOnOff", "https://www.icloud.com/shortcuts/92ef83ae8e9c4962b837a587f53d16cb", "wifi", .green, String(localized: "Wi-Fi nos Ajustes")),
        ("BluetoothOnOff", "https://www.icloud.com/shortcuts/1abe7e495e7144d5b6756fa2be930f58", "dot.radiowaves.left.and.right", .blue, String(localized: "Bluetooth nos Ajustes")),
        ("LocationOnOff", "https://www.icloud.com/shortcuts/783f2ef12bc342ef9d2f178a6afac336", "location.fill", .red, String(localized: "Privacidade e Segurança")),
        ("ClearHistoryOnOff", "https://www.icloud.com/shortcuts/78aad47b390a4f80990bd62f40ead9dc", "safari", .blue, String(localized: "Limpar histórico Safari")),
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

                // Atalhos
                Section(String(localized: "Essenciais")) {
                    ForEach(shortcuts, id: \.name) { shortcut in
                        shortcutRow(shortcut)
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

    private func shortcutRow(_ shortcut: (name: String, iCloudURL: String, icon: String, color: Color, description: String)) -> some View {
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

    private func installShortcut(_ shortcut: (name: String, iCloudURL: String, icon: String, color: Color, description: String)) {
        guard let url = URL(string: shortcut.iCloudURL) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

        withAnimation {
            installedName = shortcut.name
        }
    }
}

#Preview {
    ShortcutSetupView()
}
