import SwiftUI
import SwiftData

/// Tela de gerenciamento de perfis
struct ProfilesView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var toggleVM = ToggleViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ServiceProfile.order) private var profiles: [ServiceProfile]

    var body: some View {
        NavigationStack {
            List {
                // Perfis existentes
                Section {
                    ForEach(profiles) { profile in
                        ProfileRow(
                            profile: profile,
                            onApply: {
                                toggleVM.setModelContext(modelContext)
                                toggleVM.applyProfile(profile)
                            },
                            onEdit: {
                                if !profile.isBuiltIn {
                                    viewModel.startEditing(profile)
                                }
                            }
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let profile = profiles[index]
                            if !profile.isBuiltIn {
                                viewModel.deleteProfile(profile, context: modelContext)
                            }
                        }
                    }
                } header: {
                    Text("Perfis")
                } footer: {
                    Text("Toque em um perfil para aplicá-lo. O app abrirá os Ajustes para cada serviço.")
                }

                // Info sobre limitações
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Como funciona")
                                .font(.subheadline.weight(.semibold))
                            Text("Ao aplicar um perfil, o app redirecionará você aos Ajustes do iOS para alterar cada serviço. Isso é necessário por questões de segurança do iOS.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Perfis")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.prepareNewProfile()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewProfile) {
                ProfileFormSheet(viewModel: viewModel, isEditing: false)
            }
            .sheet(isPresented: $viewModel.showingEditProfile) {
                ProfileFormSheet(viewModel: viewModel, isEditing: true)
            }
            .onAppear {
                viewModel.seedDefaultProfilesIfNeeded(context: modelContext)
            }
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let profile: ServiceProfile
    let onApply: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button {
            onApply()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: profile.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.name)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)

                        if profile.isBuiltIn {
                            Text("Padrão")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1), in: Capsule())
                                .foregroundStyle(.blue)
                        }
                    }

                    HStack(spacing: 12) {
                        serviceIndicator("Wi-Fi", isOn: profile.wifiEnabled, color: .green)
                        serviceIndicator("BT", isOn: profile.bluetoothEnabled, color: .blue)
                        serviceIndicator("GPS", isOn: profile.locationEnabled, color: .red)
                    }
                }

                Spacer()

                if !profile.isBuiltIn {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(.secondary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .accessibilityLabel("\(profile.name): Wi-Fi \(profile.wifiEnabled ? "ligado" : "desligado"), Bluetooth \(profile.bluetoothEnabled ? "ligado" : "desligado"), GPS \(profile.locationEnabled ? "ligado" : "desligado")")
    }

    private func serviceIndicator(_ name: String, isOn: Bool, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(isOn ? color : .gray)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.caption2)
                .foregroundStyle(isOn ? .primary : .secondary)
        }
    }
}

// MARK: - Profile Form Sheet

struct ProfileFormSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    let isEditing: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Informações") {
                    TextField("Nome do perfil", text: $viewModel.profileName)

                    // Seletor de ícone
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.availableIcons, id: \.self) { icon in
                                Button {
                                    viewModel.profileIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            viewModel.profileIcon == icon
                                                ? Color.blue.opacity(0.15)
                                                : Color.gray.opacity(0.1),
                                            in: Circle()
                                        )
                                        .foregroundStyle(
                                            viewModel.profileIcon == icon ? .blue : .secondary
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Serviços") {
                    Toggle(isOn: $viewModel.wifiEnabled) {
                        Label("Wi-Fi", systemImage: "wifi")
                    }
                    .tint(.green)

                    Toggle(isOn: $viewModel.bluetoothEnabled) {
                        Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .tint(.blue)

                    Toggle(isOn: $viewModel.locationEnabled) {
                        Label("Localização", systemImage: "location.fill")
                    }
                    .tint(.red)
                }
            }
            .navigationTitle(isEditing ? "Editar Perfil" : "Novo Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if isEditing {
                            viewModel.updateProfile(context: modelContext)
                        } else {
                            viewModel.createProfile(context: modelContext)
                        }
                    }
                    .disabled(viewModel.profileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProfilesView()
}
