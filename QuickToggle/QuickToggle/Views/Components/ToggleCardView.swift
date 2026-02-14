import SwiftUI

/// Card visual para cada serviço de rádio
struct ToggleCardView: View {
    let service: RadioServiceType
    let status: ServiceStatus
    let onToggle: () -> Void
    let onOpenSettings: () -> Void

    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme

    private var isActive: Bool { status.isActive }

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 16) {
                // Ícone do serviço
                serviceIcon

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(isActive ? service.activeColor : .gray)
                            .frame(width: 8, height: 8)

                        Text(status.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Impacto na bateria
                    HStack(spacing: 4) {
                        Image(systemName: "battery.25percent")
                            .font(.caption2)
                        Text("Impacto: \(service.batteryImpact.rawValue)")
                            .font(.caption2)
                    }
                    .foregroundStyle(service.batteryImpact.color)
                }

                Spacer()

                // Botão de ajustes direto
                VStack(spacing: 8) {
                    // Status toggle visual
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isActive ? service.activeColor : Color.gray.opacity(0.3))
                            .frame(width: 52, height: 32)

                        Circle()
                            .fill(.white)
                            .frame(width: 26, height: 26)
                            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                            .offset(x: isActive ? 10 : -10)
                    }
                    .animation(.spring(response: 0.3), value: isActive)

                    // Link direto para Ajustes
                    Button {
                        onOpenSettings()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "gear")
                            Text("Ajustes")
                        }
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    }
                }
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: isActive ? service.activeColor.opacity(0.2) : .clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(CardButtonStyle())
        .accessibilityLabel("\(service.displayName), \(status.displayName)")
        .accessibilityHint("Toque duas vezes para abrir ajustes de \(service.displayName)")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    // MARK: - Service Icon

    private var serviceIcon: some View {
        ZStack {
            Circle()
                .fill(isActive
                    ? service.activeColor.opacity(0.15)
                    : Color.gray.opacity(0.1)
                )
                .frame(width: 50, height: 50)

            Image(systemName: isActive ? service.icon : service.iconOff)
                .font(.title2)
                .foregroundStyle(isActive ? service.activeColor : .gray)
                .symbolEffect(.bounce, value: isActive)
        }
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isActive
                                    ? service.activeColor.opacity(0.3)
                                    : Color.gray.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isActive
                                    ? service.activeColor.opacity(0.2)
                                    : Color.gray.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            }
        }
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        ToggleCardView(
            service: .wifi,
            status: .on,
            onToggle: {},
            onOpenSettings: {}
        )
        ToggleCardView(
            service: .bluetooth,
            status: .off,
            onToggle: {},
            onOpenSettings: {}
        )
        ToggleCardView(
            service: .location,
            status: .unknown,
            onToggle: {},
            onOpenSettings: {}
        )
    }
    .padding()
}
