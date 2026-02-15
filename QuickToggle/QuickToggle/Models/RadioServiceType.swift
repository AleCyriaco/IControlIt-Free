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
    /// Usa settings-navigation:// (iOS 26+) como formato principal.
    /// Ref: https://github.com/paralevel/ios-settings-urls
    var settingsURLScheme: String {
        switch self {
        case .wifi: return "settings-navigation://com.apple.Settings.WiFi"
        case .bluetooth: return "settings-navigation://com.apple.Settings.Bluetooth"
        case .location: return "settings-navigation://com.apple.Settings.PrivacyAndSecurity"
        }
    }

    /// Nome do Apple Shortcut que faz deep link para esta seção dos Ajustes
    var shortcutName: String {
        switch self {
        case .wifi: return "WiFiOnOff"
        case .bluetooth: return "BluetoothOnOff"
        case .location: return "LocationOnOff"
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
