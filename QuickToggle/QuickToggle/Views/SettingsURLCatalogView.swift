import SwiftUI

/// View para navegar todas as URLs de Ajustes do iOS, com busca e categorias expansíveis
struct SettingsURLCatalogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var expandedCategories: Set<String> = []

    /// Callback quando o usuário seleciona uma entry para adicionar como shortcut
    var onAddShortcut: ((SettingsURLEntry) -> Void)?

    private var filteredCategories: [SettingsURLCategory] {
        if searchText.isEmpty {
            return SettingsURLCatalog.categories
        }
        let query = searchText.lowercased()
        return SettingsURLCatalog.categories.compactMap { category in
            let filtered = category.entries.filter {
                $0.name.lowercased().contains(query) ||
                $0.fullPath.lowercased().contains(query) ||
                $0.url.lowercased().contains(query)
            }
            if filtered.isEmpty && !category.name.lowercased().contains(query) {
                return nil
            }
            if filtered.isEmpty {
                return category
            }
            return SettingsURLCategory(name: category.name, icon: category.icon, entries: filtered)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCategories) { category in
                    Section {
                        // Header da categoria (clicável para expandir)
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedCategories.contains(category.name) {
                                    expandedCategories.remove(category.name)
                                } else {
                                    expandedCategories.insert(category.name)
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                Text(category.name)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text("\(category.entries.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Image(systemName: expandedCategories.contains(category.name) || !searchText.isEmpty
                                      ? "chevron.down" : "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Entries (visíveis quando expandido ou buscando)
                        if expandedCategories.contains(category.name) || !searchText.isEmpty {
                            ForEach(category.entries) { entry in
                                entryRow(entry)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "Buscar ajuste..."))
            .navigationTitle(String(localized: "Catálogo de URLs"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Fechar")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func entryRow(_ entry: SettingsURLEntry) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(entry.url)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if let onAddShortcut {
                Button {
                    onAddShortcut(entry)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.leading, 16)
    }
}

#Preview {
    SettingsURLCatalogView()
}
