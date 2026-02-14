import Foundation
import SwiftUI
import SwiftData
import Combine

/// ViewModel principal para controle dos toggles
@MainActor
final class ToggleViewModel: ObservableObject {
    @Published var radioService = RadioControlService.shared
    @Published var batteryService = BatteryMonitorService.shared
    @Published var showingLimitationsAlert = false
    @Published var selectedService: RadioServiceType?
    @Published var showBatterySuggestion = false

    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext?

    init() {
        setupBatteryObserver()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Toggle Actions

    func toggleService(_ service: RadioServiceType) {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Registrar no histórico
        let currentStatus = radioService.status(for: service)
        let action: ToggleAction = currentStatus.isActive ? .off : .on
        logHistory(service: service, action: action, source: .manual)

        // Abrir ajustes do serviço
        radioService.openSettings(for: service)
    }

    func openSettingsForService(_ service: RadioServiceType) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        radioService.openSettings(for: service)
    }

    func turnAllOff() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.warning)

        for service in RadioServiceType.allCases {
            logHistory(service: service, action: .off, source: .manual)
        }

        // Abrir primeiro ajuste (Wi-Fi)
        radioService.openSettings(for: .wifi)
    }

    func turnAllOn() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)

        for service in RadioServiceType.allCases {
            logHistory(service: service, action: .on, source: .manual)
        }

        radioService.openSettings(for: .wifi)
    }

    // MARK: - Profile Application

    func applyProfile(_ profile: ServiceProfile) {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)

        let services: [(RadioServiceType, Bool)] = [
            (.wifi, profile.wifiEnabled),
            (.bluetooth, profile.bluetoothEnabled),
            (.location, profile.locationEnabled)
        ]

        for (service, enabled) in services {
            let action: ToggleAction = enabled ? .on : .off
            logHistory(service: service, action: action, source: .profile)
            radioService.saveState(for: service, isOn: enabled)
        }

        // Abrir ajustes para aplicar manualmente
        if let firstDisabled = services.first(where: { !$0.1 }) {
            radioService.openSettings(for: firstDisabled.0)
        }
    }

    // MARK: - History

    private func logHistory(service: RadioServiceType, action: ToggleAction, source: ToggleSource) {
        guard let context = modelContext else { return }
        let entry = ToggleHistoryEntry(serviceType: service, action: action, source: source)
        context.insert(entry)
        try? context.save()
    }

    // MARK: - Battery

    private func setupBatteryObserver() {
        batteryService.$batteryLevel
            .receive(on: RunLoop.main)
            .sink { [weak self] level in
                self?.showBatterySuggestion = level <= 0.3
            }
            .store(in: &cancellables)
    }

    var batterySavingsIfAllOff: BatterySavingsEstimate {
        batteryService.estimatedSavings(services: RadioServiceType.allCases)
    }

    // MARK: - Refresh

    func refresh() {
        radioService.detectCurrentStates()
    }
}
