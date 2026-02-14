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
        case .location: return "Localização"
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
    /// Tenta App-prefs: (funciona no simulador e maioria dos devices),
    /// depois prefs:root= e App-prefs:root= como fallback.
    var settingsURLScheme: String {
        switch self {
        case .wifi: return "App-prefs:WIFI"
        case .bluetooth: return "App-prefs:Bluetooth"
        case .location: return "App-prefs:Privacy&path=LOCATION"
        }
    }

    /// Fallbacks caso o scheme principal não funcione
    var settingsURLFallbacks: [String] {
        switch self {
        case .wifi:
            return ["prefs:root=WIFI", "App-prefs:root=WIFI"]
        case .bluetooth:
            return ["prefs:root=Bluetooth", "App-prefs:root=Bluetooth"]
        case .location:
            return ["prefs:root=Privacy&path=LOCATION", "App-prefs:root=Privacy&path=LOCATION"]
        }
    }

    /// URL alternativa usando o scheme padrão de Ajustes
    var settingsURLFallback: String {
        return "App-prefs:root"
    }

    var shortcutPhrase: String {
        switch self {
        case .wifi: return "Alternar Wi-Fi"
        case .bluetooth: return "Alternar Bluetooth"
        case .location: return "Alternar Localização"
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

    var color: Color {
        switch self {
        case .low: return .green
        case .high: return .red
        case .medium: return .orange
        }
    }
}
