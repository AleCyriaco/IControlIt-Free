import Foundation
import SwiftUI
import SwiftData

/// ViewModel para gerenciamento de perfis
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var showingNewProfile = false
    @Published var showingEditProfile = false
    @Published var editingProfile: ServiceProfile?

    // Campos do formulário
    @Published var profileName = ""
    @Published var profileIcon = "person.crop.circle"
    @Published var wifiEnabled = true
    @Published var bluetoothEnabled = true
    @Published var locationEnabled = true

    let availableIcons = [
        "person.crop.circle", "airplane", "lock.shield.fill",
        "battery.75percent", "antenna.radiowaves.left.and.right",
        "moon.fill", "house.fill", "car.fill", "figure.walk",
        "briefcase.fill", "bed.double.fill", "gamecontroller.fill",
        "book.fill", "music.note", "film", "camera.fill",
        "heart.fill", "star.fill", "bolt.fill", "leaf.fill"
    ]

    // MARK: - Create Profile

    func createProfile(context: ModelContext) {
        guard !profileName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let profile = ServiceProfile(
            name: profileName,
            icon: profileIcon,
            wifiEnabled: wifiEnabled,
            bluetoothEnabled: bluetoothEnabled,
            locationEnabled: locationEnabled
        )

        context.insert(profile)
        try? context.save()
        resetForm()
    }

    // MARK: - Update Profile

    func startEditing(_ profile: ServiceProfile) {
        editingProfile = profile
        profileName = profile.name
        profileIcon = profile.icon
        wifiEnabled = profile.wifiEnabled
        bluetoothEnabled = profile.bluetoothEnabled
        locationEnabled = profile.locationEnabled
        showingEditProfile = true
    }

    func updateProfile(context: ModelContext) {
        guard let profile = editingProfile else { return }
        profile.name = profileName
        profile.icon = profileIcon
        profile.wifiEnabled = wifiEnabled
        profile.bluetoothEnabled = bluetoothEnabled
        profile.locationEnabled = locationEnabled

        try? context.save()
        resetForm()
    }

    // MARK: - Delete Profile

    func deleteProfile(_ profile: ServiceProfile, context: ModelContext) {
        context.delete(profile)
        try? context.save()
    }

    // MARK: - Seed Default Profiles

    func seedDefaultProfilesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ServiceProfile>(
            predicate: #Predicate { $0.isBuiltIn }
        )

        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            for profile in ServiceProfile.defaultProfiles {
                context.insert(profile)
            }
            try? context.save()
        }
    }

    // MARK: - Form

    func resetForm() {
        profileName = ""
        profileIcon = "person.crop.circle"
        wifiEnabled = true
        bluetoothEnabled = true
        locationEnabled = true
        editingProfile = nil
        showingNewProfile = false
        showingEditProfile = false
    }

    func prepareNewProfile() {
        resetForm()
        showingNewProfile = true
    }
}
