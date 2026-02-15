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
                    Text("Profiles", comment: "Profiles section header")
                } footer: {
                    Text("Tap a profile to apply it. The app will open Settings for each service.", comment: "Profiles section footer")
                }

                // Info sobre limitações
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("How it works", comment: "Profiles info title")
                                .font(.subheadline.weight(.semibold))
                            Text("When applying a profile, the app will redirect you to iOS Settings to change each service. This is required due to iOS security restrictions.", comment: "Profiles info description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(String(localized: "Profiles"))
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
                            Text("Default", comment: "Built-in profile badge")
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
        .accessibilityLabel("\(profile.name): Wi-Fi \(profile.wifiEnabled ? String(localized: "on") : String(localized: "off")), Bluetooth \(profile.bluetoothEnabled ? String(localized: "on") : String(localized: "off")), GPS \(profile.locationEnabled ? String(localized: "on") : String(localized: "off"))")
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
                Section(String(localized: "Information")) {
                    TextField(String(localized: "Profile name"), text: $viewModel.profileName)

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

                Section(String(localized: "Services")) {
                    Toggle(isOn: $viewModel.wifiEnabled) {
                        Label("Wi-Fi", systemImage: "wifi")
                    }
                    .tint(.green)

                    Toggle(isOn: $viewModel.bluetoothEnabled) {
                        Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .tint(.blue)

                    Toggle(isOn: $viewModel.locationEnabled) {
                        Label(String(localized: "Location"), systemImage: "location.fill")
                    }
                    .tint(.red)
                }
            }
            .navigationTitle(isEditing ? String(localized: "Edit Profile") : String(localized: "New Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        viewModel.resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
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
