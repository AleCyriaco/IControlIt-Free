import SwiftUI

/// View para configurar um novo atalho customizado antes de adicioná-lo
struct AddCustomShortcutView: View {
    let entry: SettingsURLEntry
    var onSave: (CustomShortcut) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var shortcutName: String = ""
    @State private var selectedIcon: String = "gear"
    @State private var copiedURL = false

    private let iconOptions = [
        "gear", "wifi", "antenna.radiowaves.left.and.right", "battery.100percent",
        "lock.shield", "bell", "moon", "sun.max", "camera", "safari",
        "key", "internaldrive", "hourglass", "hand.raised", "person.crop.circle",
        "icloud", "gamecontroller", "wallet.pass", "square.grid.2x2", "accessibility",
        "location.fill", "bolt.fill", "eye", "mic", "speaker.wave.3",
        "phone", "envelope", "map", "photo", "music.note",
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Ajuste selecionado
                Section(String(localized: "Ajuste Selecionado")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.fullPath)
                            .font(.subheadline.weight(.medium))
                        Text(entry.url)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Copiar URL e abrir Atalhos
                    HStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = entry.url
                            withAnimation { copiedURL = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { copiedURL = false }
                            }
                        } label: {
                            Label(
                                copiedURL ? String(localized: "Copiado!") : String(localized: "Copiar URL"),
                                systemImage: copiedURL ? "checkmark.circle.fill" : "doc.on.doc"
                            )
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(copiedURL ? .green.opacity(0.15) : .blue.opacity(0.15), in: Capsule())
                            .foregroundStyle(copiedURL ? .green : .blue)
                        }

                        Button {
                            UIPasteboard.general.string = entry.url
                            if let url = URL(string: "shortcuts://create-shortcut") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label(String(localized: "Criar no Atalhos"), systemImage: "command")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.orange.opacity(0.15), in: Capsule())
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Configuração
                Section {
                    TextField(String(localized: "Nome de exibição"), text: $title)
                        .autocorrectionDisabled()

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(String(localized: "Nome do Shortcut"))
                            Spacer()
                            TextField(String(localized: "MeuAtalho"), text: $shortcutName)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.blue)
                                .frame(maxWidth: 180)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        Text(String(localized: "Deve ser idêntico ao nome do atalho no app Atalhos da Apple. Se deixar vazio, abrirá direto via URL."))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(String(localized: "Configuração do Atalho"))
                }

                // Ícone
                Section(String(localized: "Ícone")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 8)
                                    )
                                    .foregroundStyle(selectedIcon == icon ? .blue : .primary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Instruções
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(String(localized: "Como vincular ao Atalhos"), systemImage: "info.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 6) {
                            instructionStep("1", String(localized: "Toque \"Copiar URL\" acima"))
                            instructionStep("2", String(localized: "Toque \"Criar no Atalhos\" para abrir o app"))
                            instructionStep("3", String(localized: "Adicione a ação \"Abrir URLs\" e cole a URL"))
                            instructionStep("4", String(localized: "Dê um nome ao atalho e volte aqui"))
                            instructionStep("5", String(localized: "Preencha o mesmo nome no campo acima"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(String(localized: "Novo Atalho"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Salvar")) {
                        let shortcut = CustomShortcut(
                            title: title.isEmpty ? entry.name : title,
                            icon: selectedIcon,
                            shortcutName: shortcutName.trimmingCharacters(in: .whitespaces),
                            settingsURL: entry.url
                        )
                        onSave(shortcut)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                title = entry.name
                shortcutName = ""
            }
        }
    }

    private func instructionStep(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption2.weight(.bold))
                .frame(width: 18, height: 18)
                .background(.blue.opacity(0.15), in: Circle())
                .foregroundStyle(.blue)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
