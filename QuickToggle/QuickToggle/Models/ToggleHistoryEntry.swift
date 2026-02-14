import Foundation
import SwiftData

@Model
final class ToggleHistoryEntry {
    var id: UUID
    var serviceType: String // RadioServiceType.rawValue
    var action: String // "on" ou "off"
    var timestamp: Date
    var source: String // "manual", "profile", "schedule", "shortcut"

    init(
        serviceType: RadioServiceType,
        action: ToggleAction,
        source: ToggleSource = .manual
    ) {
        self.id = UUID()
        self.serviceType = serviceType.rawValue
        self.action = action.rawValue
        self.timestamp = Date()
        self.source = source.rawValue
    }

    var service: RadioServiceType? {
        RadioServiceType(rawValue: serviceType)
    }

    var toggleAction: ToggleAction? {
        ToggleAction(rawValue: action)
    }

    var toggleSource: ToggleSource? {
        ToggleSource(rawValue: source)
    }
}

enum ToggleAction: String, Codable {
    case on = "on"
    case off = "off"

    var displayName: String {
        switch self {
        case .on: return "Ligado"
        case .off: return "Desligado"
        }
    }

    var icon: String {
        switch self {
        case .on: return "power"
        case .off: return "power.circle"
        }
    }
}

enum ToggleSource: String, Codable, CaseIterable {
    case manual = "manual"
    case profile = "profile"
    case schedule = "schedule"
    case shortcut = "shortcut"
    case widget = "widget"

    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .profile: return "Perfil"
        case .schedule: return "Agendado"
        case .shortcut: return "Atalho"
        case .widget: return "Widget"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "hand.tap.fill"
        case .profile: return "person.crop.circle"
        case .schedule: return "clock.fill"
        case .shortcut: return "command"
        case .widget: return "square.grid.2x2"
        }
    }
}
