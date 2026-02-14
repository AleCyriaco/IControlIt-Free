import AppIntents
import UIKit

// MARK: - Enum para App Intents

enum ServiceTypeEntity: String, AppEnum {
    case wifi = "wifi"
    case bluetooth = "bluetooth"
    case location = "location"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Serviço"
    }

    static var caseDisplayRepresentations: [ServiceTypeEntity: DisplayRepresentation] {
        [
            .wifi: DisplayRepresentation(title: "Wi-Fi", image: .init(systemName: "wifi")),
            .bluetooth: DisplayRepresentation(title: "Bluetooth", image: .init(systemName: "dot.radiowaves.left.and.right")),
            .location: DisplayRepresentation(title: "Localização", image: .init(systemName: "location.fill"))
        ]
    }
}

// MARK: - Alternar Serviço Individual

struct ToggleServiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Alternar Serviço"
    static var description = IntentDescription("Abre os Ajustes do iOS para alternar um serviço de rádio")

    @Parameter(title: "Serviço")
    var service: ServiceTypeEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Alternar \(\.$service)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let radioService: RadioServiceType
        switch service {
        case .wifi: radioService = .wifi
        case .bluetooth: radioService = .bluetooth
        case .location: radioService = .location
        }

        await MainActor.run {
            RadioControlService.shared.openSettings(for: radioService)
        }

        return .result(dialog: "Abrindo Ajustes de \(radioService.displayName)...")
    }

    static var openAppWhenRun: Bool { true }
}

// MARK: - Desligar Tudo

struct TurnAllOffIntent: AppIntent {
    static var title: LocalizedStringResource = "Desligar Tudo"
    static var description = IntentDescription("Abre os Ajustes para desligar Wi-Fi, Bluetooth e GPS")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .wifi)
        }

        return .result(dialog: "Abrindo Ajustes para desligar todos os serviços...")
    }
}

// MARK: - Ligar Tudo

struct TurnAllOnIntent: AppIntent {
    static var title: LocalizedStringResource = "Ligar Tudo"
    static var description = IntentDescription("Abre os Ajustes para ligar Wi-Fi, Bluetooth e GPS")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .wifi)
        }

        return .result(dialog: "Abrindo Ajustes para ligar todos os serviços...")
    }
}

// MARK: - Modo Privacidade

struct PrivacyModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Modo Privacidade"
    static var description = IntentDescription("Desliga GPS e Wi-Fi, mantém Bluetooth")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .location)
        }

        return .result(dialog: "Abrindo Ajustes para ativar modo privacidade...")
    }
}

// MARK: - Modo Economia

struct BatterySavingModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Economia de Bateria"
    static var description = IntentDescription("Desliga Bluetooth e GPS para economizar bateria")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .bluetooth)
        }

        return .result(dialog: "Abrindo Ajustes para economizar bateria...")
    }
}

// MARK: - Alternar Wi-Fi (Atalho dedicado)

struct ToggleWiFiIntent: AppIntent {
    static var title: LocalizedStringResource = "Alternar Wi-Fi"
    static var description = IntentDescription("Abre os Ajustes de Wi-Fi")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .wifi)
        }
        return .result(dialog: "Abrindo Ajustes de Wi-Fi...")
    }
}

// MARK: - Alternar Bluetooth (Atalho dedicado)

struct ToggleBluetoothIntent: AppIntent {
    static var title: LocalizedStringResource = "Alternar Bluetooth"
    static var description = IntentDescription("Abre os Ajustes de Bluetooth")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .bluetooth)
        }
        return .result(dialog: "Abrindo Ajustes de Bluetooth...")
    }
}

// MARK: - Alternar Localização (Atalho dedicado)

struct ToggleLocationIntent: AppIntent {
    static var title: LocalizedStringResource = "Alternar Localização"
    static var description = IntentDescription("Abre os Ajustes de Localização")

    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        await MainActor.run {
            RadioControlService.shared.openSettings(for: .location)
        }
        return .result(dialog: "Abrindo Ajustes de Localização...")
    }
}

// MARK: - App Shortcuts Provider

struct QuickToggleShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TurnAllOffIntent(),
            phrases: [
                "Desligar tudo no \(.applicationName)",
                "Desliga tudo no \(.applicationName)",
                "\(.applicationName) desligar tudo"
            ],
            shortTitle: "Desligar Tudo",
            systemImageName: "power"
        )

        AppShortcut(
            intent: TurnAllOnIntent(),
            phrases: [
                "Ligar tudo no \(.applicationName)",
                "Liga tudo no \(.applicationName)",
                "\(.applicationName) ligar tudo"
            ],
            shortTitle: "Ligar Tudo",
            systemImageName: "bolt.fill"
        )

        AppShortcut(
            intent: ToggleWiFiIntent(),
            phrases: [
                "Alternar Wi-Fi no \(.applicationName)",
                "\(.applicationName) Wi-Fi"
            ],
            shortTitle: "Alternar Wi-Fi",
            systemImageName: "wifi"
        )

        AppShortcut(
            intent: ToggleBluetoothIntent(),
            phrases: [
                "Alternar Bluetooth no \(.applicationName)",
                "\(.applicationName) Bluetooth"
            ],
            shortTitle: "Alternar Bluetooth",
            systemImageName: "dot.radiowaves.left.and.right"
        )

        AppShortcut(
            intent: ToggleLocationIntent(),
            phrases: [
                "Alternar Localização no \(.applicationName)",
                "\(.applicationName) GPS"
            ],
            shortTitle: "Alternar GPS",
            systemImageName: "location.fill"
        )

        AppShortcut(
            intent: PrivacyModeIntent(),
            phrases: [
                "Modo privacidade no \(.applicationName)",
                "\(.applicationName) privacidade"
            ],
            shortTitle: "Modo Privacidade",
            systemImageName: "lock.shield.fill"
        )

        AppShortcut(
            intent: BatterySavingModeIntent(),
            phrases: [
                "Economia de bateria no \(.applicationName)",
                "\(.applicationName) economizar bateria"
            ],
            shortTitle: "Economia de Bateria",
            systemImageName: "battery.75percent"
        )
    }
}
