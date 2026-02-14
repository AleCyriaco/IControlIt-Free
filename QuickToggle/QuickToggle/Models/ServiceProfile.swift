import Foundation
import SwiftData

@Model
final class ServiceProfile {
    var id: UUID
    var name: String
    var icon: String
    var wifiEnabled: Bool
    var bluetoothEnabled: Bool
    var locationEnabled: Bool
    var isBuiltIn: Bool
    var createdAt: Date
    var order: Int

    init(
        name: String,
        icon: String = "person.crop.circle",
        wifiEnabled: Bool = true,
        bluetoothEnabled: Bool = true,
        locationEnabled: Bool = true,
        isBuiltIn: Bool = false,
        order: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.wifiEnabled = wifiEnabled
        self.bluetoothEnabled = bluetoothEnabled
        self.locationEnabled = locationEnabled
        self.isBuiltIn = isBuiltIn
        self.createdAt = Date()
        self.order = order
    }

    /// Perfis padrão do sistema
    static var defaultProfiles: [ServiceProfile] {
        [
            ServiceProfile(
                name: "Avião Plus",
                icon: "airplane",
                wifiEnabled: false,
                bluetoothEnabled: false,
                locationEnabled: false,
                isBuiltIn: true,
                order: 0
            ),
            ServiceProfile(
                name: "Privacidade",
                icon: "lock.shield.fill",
                wifiEnabled: false,
                bluetoothEnabled: true,
                locationEnabled: false,
                isBuiltIn: true,
                order: 1
            ),
            ServiceProfile(
                name: "Economia",
                icon: "battery.75percent",
                wifiEnabled: true,
                bluetoothEnabled: false,
                locationEnabled: false,
                isBuiltIn: true,
                order: 2
            ),
            ServiceProfile(
                name: "Tudo Ligado",
                icon: "antenna.radiowaves.left.and.right",
                wifiEnabled: true,
                bluetoothEnabled: true,
                locationEnabled: true,
                isBuiltIn: true,
                order: 3
            )
        ]
    }
}
