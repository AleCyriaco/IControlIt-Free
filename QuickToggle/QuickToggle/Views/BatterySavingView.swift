import SwiftUI

/// Tela de detalhes de economia de bateria
struct BatterySavingView: View {
    @StateObject private var batteryService = BatteryMonitorService.shared
    @State private var selectedServices: Set<RadioServiceType> = []

    var body: some View {
        List {
            // Status da bateria
            Section {
                VStack(spacing: 16) {
                    // Indicador visual de bateria
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(batteryService.batteryLevel))
                            .stroke(
                                Color(batteryService.batteryColor),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 120, height: 120)
                            .animation(.easeInOut(duration: 0.5), value: batteryService.batteryLevel)

                        VStack(spacing: 2) {
                            Text("\(batteryService.batteryPercentage)%")
                                .font(.title.weight(.bold).monospacedDigit())
                            Image(systemName: batteryService.batteryIcon)
                                .font(.caption)
                                .foregroundStyle(Color(batteryService.batteryColor))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                    if batteryService.isLowPowerMode {
                        Label(String(localized: "Low Power Mode active"), systemImage: "bolt.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.yellow.opacity(0.1), in: Capsule())
                    }
                }
            }

            // Impacto por serviço
            Section(String(localized: "Consumption per Service")) {
                ForEach(RadioServiceType.allCases) { service in
                    HStack(spacing: 14) {
                        Image(systemName: service.icon)
                            .foregroundStyle(service.activeColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.displayName)
                                .font(.body)

                            HStack(spacing: 8) {
                                // Barra de impacto
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 6)

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(service.batteryImpact.color)
                                            .frame(
                                                width: geometry.size.width * impactFraction(service),
                                                height: 6
                                            )
                                    }
                                }
                                .frame(height: 6)

                                Text(service.batteryImpact.displayName)
                                    .font(.caption2)
                                    .foregroundStyle(service.batteryImpact.color)
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }

                        Spacer()

                        // Toggle para simulação
                        Button {
                            toggleServiceSelection(service)
                        } label: {
                            Image(systemName: selectedServices.contains(service)
                                  ? "checkmark.circle.fill"
                                  : "circle")
                                .foregroundStyle(selectedServices.contains(service) ? .green : .gray)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Economia estimada
            Section {
                if selectedServices.isEmpty {
                    HStack {
                        Image(systemName: "hand.tap")
                            .foregroundStyle(.secondary)
                        Text("Select services above to see estimated savings", comment: "Battery savings empty state")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    let estimate = batteryService.estimatedSavings(
                        services: Array(selectedServices)
                    )

                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            savingsMetric(
                                value: estimate.formattedPercent,
                                label: String(localized: "savings/hour"),
                                icon: "percent"
                            )

                            savingsMetric(
                                value: estimate.formattedMinutes,
                                label: String(localized: "extra/day"),
                                icon: "clock"
                            )

                            savingsMetric(
                                value: String(format: "%.0f", estimate.mahPerHour),
                                label: String(localized: "mAh/hour"),
                                icon: "bolt"
                            )
                        }

                        // Serviços selecionados
                        HStack(spacing: 8) {
                            Text("Turning off:", comment: "Label before list of services to disable")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ForEach(Array(selectedServices)) { service in
                                Label(service.displayName, systemImage: service.icon)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(service.activeColor.opacity(0.1), in: Capsule())
                                    .foregroundStyle(service.activeColor)
                            }
                        }

                        // Botão para aplicar
                        Button {
                            applyBatterySaving()
                        } label: {
                            Label(String(localized: "Open Settings to turn off"), systemImage: "arrow.right")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Estimated Savings", comment: "Battery estimated savings section header")
            } footer: {
                Text("* Values are estimates based on average consumption. Actual consumption may vary depending on usage, signal strength, and other factors.", comment: "Battery savings disclaimer")
            }

            // Dicas
            Section(String(localized: "Battery Saving Tips")) {
                tipRow(
                    icon: "wifi.slash",
                    title: String(localized: "Turn off Wi-Fi when not in use"),
                    description: String(localized: "Wi-Fi consumes power searching for available networks")
                )
                tipRow(
                    icon: "location.slash",
                    title: String(localized: "GPS is the biggest consumer"),
                    description: String(localized: "Turn it off when you don't need navigation or tracking")
                )
                tipRow(
                    icon: "moon.fill",
                    title: String(localized: "Schedule shutdowns at night"),
                    description: String(localized: "Use the Schedule tab to automatically turn off services at bedtime")
                )
                tipRow(
                    icon: "battery.75percent",
                    title: String(localized: "iOS Low Power Mode"),
                    description: String(localized: "Combine with iOS Low Power Mode for best results")
                )
            }
        }
        .navigationTitle(String(localized: "Battery Saving"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func impactFraction(_ service: RadioServiceType) -> Double {
        switch service.batteryImpact {
        case .low: return 0.3
        case .medium: return 0.6
        case .high: return 1.0
        }
    }

    private func toggleServiceSelection(_ service: RadioServiceType) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }

    private func applyBatterySaving() {
        if let first = selectedServices.first {
            RadioControlService.shared.openSettings(for: first)
        }
    }

    private func savingsMetric(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
            Text(value)
                .font(.headline.weight(.bold).monospacedDigit())
                .foregroundStyle(.green)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        BatterySavingView()
    }
}
