import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Provider

struct QuickToggleProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickToggleEntry {
        QuickToggleEntry(
            date: Date(),
            wifiOn: true,
            bluetoothOn: true,
            locationOn: true,
            batteryLevel: 75
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickToggleEntry) -> Void) {
        let entry = readCurrentState()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickToggleEntry>) -> Void) {
        let entry = readCurrentState()
        // Atualizar a cada 15 minutos
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func readCurrentState() -> QuickToggleEntry {
        let defaults = UserDefaults(suiteName: "group.com.quicktoggle.shared")
        return QuickToggleEntry(
            date: Date(),
            wifiOn: defaults?.bool(forKey: "quicktoggle_wifi_state") ?? true,
            bluetoothOn: defaults?.bool(forKey: "quicktoggle_bluetooth_state") ?? true,
            locationOn: defaults?.bool(forKey: "quicktoggle_location_state") ?? true,
            batteryLevel: defaults?.integer(forKey: "quicktoggle_battery_level") ?? 100
        )
    }
}

// MARK: - Timeline Entry

struct QuickToggleEntry: TimelineEntry {
    let date: Date
    let wifiOn: Bool
    let bluetoothOn: Bool
    let locationOn: Bool
    let batteryLevel: Int
}

// MARK: - Widget Intents (para interatividade iOS 17+)

struct WidgetToggleWiFiIntent: AppIntent {
    static var title: LocalizedStringResource = "Wi-Fi"
    static var description = IntentDescription("Abrir ajustes de Wi-Fi")
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        // openAppWhenRun abre o app, que tratará a navegação para Ajustes
        UserDefaults(suiteName: "group.com.quicktoggle.shared")?
            .set("wifi", forKey: "pending_toggle_action")
        return .result()
    }
}

struct WidgetToggleBluetoothIntent: AppIntent {
    static var title: LocalizedStringResource = "Bluetooth"
    static var description = IntentDescription("Abrir ajustes de Bluetooth")
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: "group.com.quicktoggle.shared")?
            .set("bluetooth", forKey: "pending_toggle_action")
        return .result()
    }
}

struct WidgetToggleLocationIntent: AppIntent {
    static var title: LocalizedStringResource = "Localização"
    static var description = IntentDescription("Abrir ajustes de Localização")
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: "group.com.quicktoggle.shared")?
            .set("location", forKey: "pending_toggle_action")
        return .result()
    }
}

// MARK: - Widget Views

struct QuickToggleWidgetEntryView: View {
    var entry: QuickToggleProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        case .accessoryCircular:
            accessoryCircularWidget
        case .accessoryRectangular:
            accessoryRectangularWidget
        default:
            mediumWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(spacing: 8) {
            Text("QuickToggle")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                serviceCircle(
                    icon: "wifi",
                    isOn: entry.wifiOn,
                    color: .green
                )
                serviceCircle(
                    icon: "dot.radiowaves.left.and.right",
                    isOn: entry.bluetoothOn,
                    color: .blue
                )
                serviceCircle(
                    icon: "location.fill",
                    isOn: entry.locationOn,
                    color: .red
                )
            }

            Text("\(entry.batteryLevel)%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // Toggle buttons interativos (iOS 17+)
            Button(intent: WidgetToggleWiFiIntent()) {
                widgetToggleButton(
                    icon: "wifi",
                    label: "Wi-Fi",
                    isOn: entry.wifiOn,
                    color: .green
                )
            }
            .buttonStyle(.plain)

            Button(intent: WidgetToggleBluetoothIntent()) {
                widgetToggleButton(
                    icon: "dot.radiowaves.left.and.right",
                    label: "Bluetooth",
                    isOn: entry.bluetoothOn,
                    color: .blue
                )
            }
            .buttonStyle(.plain)

            Button(intent: WidgetToggleLocationIntent()) {
                widgetToggleButton(
                    icon: "location.fill",
                    label: "GPS",
                    isOn: entry.locationOn,
                    color: .red
                )
            }
            .buttonStyle(.plain)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Large Widget

    private var largeWidget: some View {
        VStack(spacing: 12) {
            HStack {
                Text("QuickToggle")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "battery.75percent")
                    Text("\(entry.batteryLevel)%")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Divider()

            // Wi-Fi
            Button(intent: WidgetToggleWiFiIntent()) {
                widgetRow(
                    icon: "wifi",
                    name: "Wi-Fi",
                    isOn: entry.wifiOn,
                    color: .green,
                    impact: "Impacto: Médio"
                )
            }
            .buttonStyle(.plain)

            // Bluetooth
            Button(intent: WidgetToggleBluetoothIntent()) {
                widgetRow(
                    icon: "dot.radiowaves.left.and.right",
                    name: "Bluetooth",
                    isOn: entry.bluetoothOn,
                    color: .blue,
                    impact: "Impacto: Baixo"
                )
            }
            .buttonStyle(.plain)

            // Localização
            Button(intent: WidgetToggleLocationIntent()) {
                widgetRow(
                    icon: "location.fill",
                    name: "Localização",
                    isOn: entry.locationOn,
                    color: .red,
                    impact: "Impacto: Alto"
                )
            }
            .buttonStyle(.plain)

            Divider()

            HStack(spacing: 8) {
                Text("Toque para abrir Ajustes")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Accessory Widgets (Lock Screen)

    private var accessoryCircularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "power")
                    .font(.title3)
                Text("\(activeCount)")
                    .font(.caption2.weight(.bold))
            }
        }
    }

    private var accessoryRectangularWidget: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("QuickToggle")
                    .font(.headline)

                HStack(spacing: 4) {
                    statusDot(isOn: entry.wifiOn, color: .green)
                    statusDot(isOn: entry.bluetoothOn, color: .blue)
                    statusDot(isOn: entry.locationOn, color: .red)
                    Text("\(activeCount)/3 ativos")
                        .font(.caption2)
                }
            }
            Spacer()
        }
    }

    // MARK: - Helper Views

    private func serviceCircle(icon: String, isOn: Bool, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(isOn ? color.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 36, height: 36)

            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isOn ? color : .gray)
        }
    }

    private func widgetToggleButton(icon: String, label: String, isOn: Bool, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isOn ? color.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)

                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isOn ? color : .gray)

                    Circle()
                        .fill(isOn ? color : .gray)
                        .frame(width: 6, height: 6)
                }
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func widgetRow(icon: String, name: String, isOn: Bool, color: Color, impact: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(isOn ? color : .gray)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body.weight(.medium))
                Text(impact)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(isOn ? color : .gray)
                    .frame(width: 8, height: 8)
                Text(isOn ? "Ligado" : "Desligado")
                    .font(.caption)
                    .foregroundStyle(isOn ? color : .secondary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isOn ? color.opacity(0.05) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
    }

    private func statusDot(isOn: Bool, color: Color) -> some View {
        Circle()
            .fill(isOn ? color : .gray)
            .frame(width: 6, height: 6)
    }

    private var activeCount: Int {
        [entry.wifiOn, entry.bluetoothOn, entry.locationOn].filter { $0 }.count
    }
}

// MARK: - Widget Configuration

struct QuickToggleWidget: Widget {
    let kind: String = "QuickToggleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickToggleProvider()) { entry in
            QuickToggleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("QuickToggle")
        .description("Controle rápido de Wi-Fi, Bluetooth e GPS")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    QuickToggleWidget()
} timeline: {
    QuickToggleEntry(date: .now, wifiOn: true, bluetoothOn: true, locationOn: false, batteryLevel: 85)
}

#Preview("Medium", as: .systemMedium) {
    QuickToggleWidget()
} timeline: {
    QuickToggleEntry(date: .now, wifiOn: true, bluetoothOn: false, locationOn: true, batteryLevel: 62)
}

#Preview("Large", as: .systemLarge) {
    QuickToggleWidget()
} timeline: {
    QuickToggleEntry(date: .now, wifiOn: true, bluetoothOn: true, locationOn: true, batteryLevel: 45)
}
