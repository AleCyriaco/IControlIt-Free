import Foundation
import UIKit
import Combine

/// Serviço para monitorar bateria e estimar economia
final class BatteryMonitorService: ObservableObject {
    static let shared = BatteryMonitorService()

    @Published var batteryLevel: Float = 1.0
    @Published var batteryState: UIDevice.BatteryState = .unknown
    @Published var isLowPowerMode: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryInfo()
        startMonitoring()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        // Monitorar nível de bateria
        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateBatteryInfo()
            }
            .store(in: &cancellables)

        // Monitorar estado de bateria
        NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateBatteryInfo()
            }
            .store(in: &cancellables)

        // Monitorar modo de economia de energia
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                self?.updateLowPowerMode()
            }
            .store(in: &cancellables)
    }

    private func updateBatteryInfo() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
        updateLowPowerMode()
    }

    private func updateLowPowerMode() {
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    // MARK: - Battery Estimates

    var batteryPercentage: Int {
        Int(batteryLevel * 100)
    }

    var batteryIcon: String {
        switch batteryState {
        case .charging, .full:
            return "battery.100.bolt"
        default:
            if batteryLevel > 0.75 { return "battery.100percent" }
            if batteryLevel > 0.5 { return "battery.75percent" }
            if batteryLevel > 0.25 { return "battery.50percent" }
            return "battery.25percent"
        }
    }

    var batteryColor: UIColor {
        if batteryState == .charging { return .systemGreen }
        if batteryLevel > 0.5 { return .systemGreen }
        if batteryLevel > 0.2 { return .systemYellow }
        return .systemRed
    }

    /// Estima economia de bateria por hora ao desligar serviços
    func estimatedSavings(services: [RadioServiceType]) -> BatterySavingsEstimate {
        let totalMahSaved = services.reduce(0.0) { $0 + $1.batteryEstimateMahPerHour }
        let batteryCapacityMah: Double = 3274 // Média iPhone recente

        let percentPerHour = (totalMahSaved / batteryCapacityMah) * 100
        let minutesSaved = (totalMahSaved / batteryCapacityMah) * 60 * 24 // projeção diária

        return BatterySavingsEstimate(
            servicesOff: services,
            mahPerHour: totalMahSaved,
            percentPerHour: percentPerHour,
            estimatedMinutesSavedDaily: minutesSaved
        )
    }

    /// Sugere serviços para desligar baseado no nível de bateria
    var suggestedServicesToDisable: [RadioServiceType] {
        if batteryLevel <= 0.1 {
            return [.wifi, .bluetooth, .location]
        } else if batteryLevel <= 0.2 {
            return [.bluetooth, .location]
        } else if batteryLevel <= 0.3 {
            return [.location]
        }
        return []
    }

    var hasSuggestion: Bool {
        !suggestedServicesToDisable.isEmpty
    }
}

// MARK: - BatterySavingsEstimate

struct BatterySavingsEstimate {
    let servicesOff: [RadioServiceType]
    let mahPerHour: Double
    let percentPerHour: Double
    let estimatedMinutesSavedDaily: Double

    var formattedPercent: String {
        String(format: "%.1f%%", percentPerHour)
    }

    var formattedMinutes: String {
        let hours = Int(estimatedMinutesSavedDaily / 60)
        let mins = Int(estimatedMinutesSavedDaily.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return "\(hours)h \(mins)min"
        }
        return "\(mins)min"
    }
}
