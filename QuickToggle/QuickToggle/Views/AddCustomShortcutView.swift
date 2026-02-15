import SwiftUI

/// View para configurar um novo atalho customizado antes de adicioná-lo
struct AddCustomShortcutView: View {
    let entry: SettingsURLEntry
    var onSave: (CustomShortcut) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var shortcutName: String = ""
    @State private var selectedIcon: String = "gear"

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
                Section(String(localized: "Ajuste Selecionado")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.fullPath)
                            .font(.subheadline.weight(.medium))
                        Text(entry.url)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(String(localized: "Configuração do Atalho")) {
                    TextField(String(localized: "Nome de exibição"), text: $title)

                    HStack {
                        Text(String(localized: "Nome do Shortcut"))
                        Spacer()
                        TextField("MeuAtalho", text: $shortcutName)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: 180)
                    }
                }

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

                Section {
                    Text(String(localized: "O nome do Shortcut deve corresponder exatamente ao atalho criado no app Atalhos da Apple."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                            shortcutName: shortcutName.isEmpty ? entry.name : shortcutName,
                            settingsURL: entry.url
                        )
                        onSave(shortcut)
                    }
                    .disabled(shortcutName.isEmpty && title.isEmpty)
                }
            }
            .onAppear {
                title = entry.name
                // Sugerir nome do shortcut baseado no nome
                shortcutName = entry.name
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: ">", with: "")
            }
        }
    }
}
