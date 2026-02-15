import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .toggles
    @State private var pendingProfileName: String?
    @State private var showBatterySaving = false
    @State private var showLimitations = false
    @Environment(\.modelContext) private var modelContext

    enum Tab: String, CaseIterable {
        case toggles, profiles, schedule, history, settings

        var title: LocalizedStringKey {
            switch self {
            case .toggles: return "Controles"
            case .profiles: return "Perfis"
            case .schedule: return "Agenda"
            case .history: return "Histórico"
            case .settings: return "Ajustes"
            }
        }

        var icon: String {
            switch self {
            case .toggles: return "power"
            case .profiles: return "person.2.fill"
            case .schedule: return "clock.fill"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .toggles:
                        MainToggleView()
                    case .profiles:
                        ProfilesView()
                    case .schedule:
                        ScheduleView()
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView()
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .tint(.blue)
        .onOpenURL { url in
            // quicktoggle://tab/profiles, quicktoggle://tab/schedule, etc.
            if url.host == "tab", let tabName = url.pathComponents.last,
               let tab = Tab.allCases.first(where: { "\($0)".lowercased() == tabName }) {
                selectedTab = tab
            }
            // quicktoggle://profile/economia, quicktoggle://profile/aviao-plus, etc.
            else if url.host == "profile", let profileSlug = url.pathComponents.last {
                selectedTab = .profiles
                applyProfileBySlug(profileSlug)
            }
            // quicktoggle://create-profile?name=Trabalho&wifi=on&bt=off&gps=off&icon=briefcase.fill
            else if url.host == "create-profile" {
                selectedTab = .profiles
                createProfileFromURL(url)
            }
            // quicktoggle://create-schedule?name=GPS+noite&service=location&action=off&hour=23&minute=0&days=1,2,3,4,5,6,7
            else if url.host == "create-schedule" {
                selectedTab = .schedule
                createScheduleFromURL(url)
            }
            // quicktoggle://preset/0, quicktoggle://preset/1, etc.
            else if url.host == "preset", let indexStr = url.pathComponents.last, let index = Int(indexStr) {
                selectedTab = .schedule
                applyPreset(index: index)
            }
            // quicktoggle://open-settings/safari, quicktoggle://open-settings/wifi, etc.
            else if url.host == "open-settings", let target = url.pathComponents.last {
                openSettingsTarget(target)
            }
            // quicktoggle://battery
            else if url.host == "battery" {
                selectedTab = .settings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showBatterySaving = true
                }
            }
            // quicktoggle://limitations
            else if url.host == "limitations" {
                selectedTab = .settings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showLimitations = true
                }
            }
        }
        .sheet(isPresented: $showBatterySaving) {
            NavigationStack {
                BatterySavingView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fechar") { showBatterySaving = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showLimitations) {
            NavigationStack {
                LimitationsView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fechar") { showLimitations = false }
                        }
                    }
            }
        }
    }

    private func createProfileFromURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        let name = queryItems.first(where: { $0.name == "name" })?.value ?? "Novo Perfil"
        let wifi = queryItems.first(where: { $0.name == "wifi" })?.value == "on"
        let bt = queryItems.first(where: { $0.name == "bt" })?.value == "on"
        let gps = queryItems.first(where: { $0.name == "gps" })?.value == "on"
        let icon = queryItems.first(where: { $0.name == "icon" })?.value ?? "star.fill"

        let profile = ServiceProfile(
            name: name,
            icon: icon,
            wifiEnabled: wifi,
            bluetoothEnabled: bt,
            locationEnabled: gps
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }

    private func createScheduleFromURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        let name = queryItems.first(where: { $0.name == "name" })?.value ?? "Agendamento"
        let serviceStr = queryItems.first(where: { $0.name == "service" })?.value ?? "wifi"
        let actionStr = queryItems.first(where: { $0.name == "action" })?.value ?? "off"
        let hour = Int(queryItems.first(where: { $0.name == "hour" })?.value ?? "22") ?? 22
        let minute = Int(queryItems.first(where: { $0.name == "minute" })?.value ?? "0") ?? 0
        let daysStr = queryItems.first(where: { $0.name == "days" })?.value ?? ""
        let days = daysStr.split(separator: ",").compactMap { Int($0) }

        let service = RadioServiceType(rawValue: serviceStr) ?? .wifi
        let action = ToggleAction(rawValue: actionStr) ?? .off

        let schedule = ScheduledAction(
            name: name,
            serviceType: service,
            action: action,
            hour: hour,
            minute: minute,
            repeatDays: days
        )
        modelContext.insert(schedule)
        try? modelContext.save()

        // Agendar notificação
        NotificationService.shared.scheduleToggleReminder(
            id: schedule.notificationID,
            service: service,
            action: action,
            hour: hour,
            minute: minute,
            repeatDays: days
        )
    }

    private func openSettingsTarget(_ target: String) {
        let urlString: String
        switch target {
        case "safari": urlString = "settings-navigation://com.apple.Settings.Apps/com.apple.mobilesafari#CLEAR_HISTORY_AND_DATA"
        case "wifi": urlString = "settings-navigation://com.apple.Settings.WiFi"
        case "bluetooth": urlString = "settings-navigation://com.apple.Settings.Bluetooth"
        case "location": urlString = "settings-navigation://com.apple.Settings.PrivacyAndSecurity"
        default: urlString = "settings-navigation://com.apple.Settings"
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func applyPreset(index: Int) {
        let presets = SchedulePreset.presets
        guard index >= 0 && index < presets.count else { return }
        let preset = presets[index]

        let schedule = ScheduledAction(
            name: preset.name,
            serviceType: preset.service,
            action: preset.action,
            hour: preset.hour,
            minute: preset.minute,
            repeatDays: preset.days
        )
        modelContext.insert(schedule)
        try? modelContext.save()

        NotificationService.shared.scheduleToggleReminder(
            id: schedule.notificationID,
            service: preset.service,
            action: preset.action,
            hour: preset.hour,
            minute: preset.minute,
            repeatDays: preset.days
        )
    }

    private func applyProfileBySlug(_ slug: String) {
        let descriptor = FetchDescriptor<ServiceProfile>()
        guard let profiles = try? modelContext.fetch(descriptor) else { return }

        let normalizedSlug = slug.lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")

        if let profile = profiles.first(where: {
            let name = $0.name.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            let nameSlug = name.replacingOccurrences(of: " ", with: "-")
            return name == normalizedSlug || nameSlug == slug.lowercased()
        }) {
            let vm = ToggleViewModel()
            vm.setModelContext(modelContext)
            vm.applyProfile(profile)
        }
    }
}

#Preview {
    ContentView()
}
