import SwiftUI

extension Color {
    /// Cor de fundo glassmorphism
    static var glassBackground: Color {
        Color(.systemBackground).opacity(0.7)
    }

    /// Cor para cards
    static var cardBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }
}

extension View {
    /// Aplica estilo glassmorphism
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}
