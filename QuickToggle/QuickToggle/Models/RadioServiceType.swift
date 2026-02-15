import SwiftUI

/// Tipos de serviços de rádio que podem ser controlados
enum RadioServiceType: String, CaseIterable, Codable, Identifiable {
    case wifi = "wifi"
    case bluetooth = "bluetooth"
    case location = "location"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .bluetooth: return "Bluetooth"
        case .location: return String(localized: "Localização")
        }
    }

    var icon: String {
        switch self {
        case .wifi: return "wifi"
        case .bluetooth: return "dot.radiowaves.left.and.right"
        case .location: return "location.fill"
        }
    }

    var iconOff: String {
        switch self {
        case .wifi: return "wifi.slash"
        case .bluetooth: return "dot.radiowaves.left.and.right"
        case .location: return "location.slash.fill"
        }
    }

    var activeColor: Color {
        switch self {
        case .wifi: return .green
        case .bluetooth: return .blue
        case .location: return .red
        }
    }

    /// URL Schemes para abrir a seção exata dos Ajustes do iOS.
    /// Usa prefs:root= como primário (mesmo formato do app Atalhos da Apple).
    var settingsURLScheme: String {
        switch self {
        case .wifi: return "prefs:root=WIFI"
        case .bluetooth: return "prefs:root=Bluetooth"
        case .location: return "prefs:root=Privacy&path=LOCATION"
        }
    }

    /// Fallbacks caso o scheme principal não funcione
    var settingsURLFallbacks: [String] {
        switch self {
        case .wifi:
            return ["App-prefs:WIFI", "App-prefs:root=WIFI"]
        case .bluetooth:
            return ["App-prefs:Bluetooth", "App-prefs:root=Bluetooth"]
        case .location:
            return ["App-prefs:Privacy&path=LOCATION", "App-prefs:root=Privacy&path=LOCATION"]
        }
    }

    /// URL alternativa usando o scheme padrão de Ajustes
    var settingsURLFallback: String {
        return "App-prefs:root"
    }

    /// Nome do Apple Shortcut que faz deep link para esta seção dos Ajustes
    var shortcutName: String {
        switch self {
        case .wifi: return "WiFi"
        case .bluetooth: return "Bluetooth"
        case .location: return "GPS"
        }
    }

    var shortcutPhrase: String {
        switch self {
        case .wifi: return String(localized: "Alternar Wi-Fi")
        case .bluetooth: return String(localized: "Alternar Bluetooth")
        case .location: return String(localized: "Alternar Localização")
        }
    }

    var batteryImpact: BatteryImpact {
        switch self {
        case .wifi: return .medium
        case .bluetooth: return .low
        case .location: return .high
        }
    }

    var batteryEstimateMahPerHour: Double {
        switch self {
        case .wifi: return 80
        case .bluetooth: return 30
        case .location: return 150
        }
    }
}

enum BatteryImpact: String, Codable {
    case low = "Baixo"
    case medium = "Médio"
    case high = "Alto"

    var displayName: String {
        switch self {
        case .low: return String(localized: "Baixo")
        case .medium: return String(localized: "Médio")
        case .high: return String(localized: "Alto")
        }
    }

    var color: Color {
        switch self {
        case .low: return .green
        case .high: return .red
        case .medium: return .orange
        }
    }
}
