import WidgetKit
import SwiftUI

// MARK: - Control Center Widgets (iOS 18+)

/// Widget de Control Center para Wi-Fi
@available(iOS 18.0, *)
struct WiFiControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.quicktoggle.wifi-control") {
            ControlWidgetButton(action: ToggleWiFiIntent()) {
                Label("Wi-Fi", systemImage: "wifi")
            }
        }
        .displayName("Wi-Fi")
        .description("Abrir ajustes de Wi-Fi")
    }
}

/// Widget de Control Center para Bluetooth
@available(iOS 18.0, *)
struct BluetoothControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.quicktoggle.bluetooth-control") {
            ControlWidgetButton(action: ToggleBluetoothIntent()) {
                Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
            }
        }
        .displayName("Bluetooth")
        .description("Abrir ajustes de Bluetooth")
    }
}

/// Widget de Control Center para Localização
@available(iOS 18.0, *)
struct LocationControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.quicktoggle.location-control") {
            ControlWidgetButton(action: ToggleLocationIntent()) {
                Label("GPS", systemImage: "location.fill")
            }
        }
        .displayName("Localização")
        .description("Abrir ajustes de Localização")
    }
}
