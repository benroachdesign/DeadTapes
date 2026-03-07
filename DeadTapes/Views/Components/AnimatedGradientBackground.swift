import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var colors: [Color] = [
        DeadTheme.Colors.psychPurple.opacity(0.3),
        DeadTheme.Colors.psychPink.opacity(0.2),
        DeadTheme.Colors.psychBlue.opacity(0.25),
        DeadTheme.Colors.background
    ]

    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [animateGradient ? 0.0 : 0.1, 0.5],
                [animateGradient ? 0.8 : 0.5, animateGradient ? 0.3 : 0.5],
                [animateGradient ? 0.9 : 1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                colors.count > 0 ? colors[0] : .clear,
                colors.count > 1 ? colors[1] : .clear,
                colors.count > 2 ? colors[2] : .clear,
                colors.count > 3 ? colors[3] : .clear,
                colors.count > 0 ? colors[0].opacity(0.5) : .clear,
                colors.count > 1 ? colors[1].opacity(0.5) : .clear,
                DeadTheme.Colors.background,
                DeadTheme.Colors.background,
                DeadTheme.Colors.background
            ]
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6.0)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                DeadTheme.Colors.cardBackground.opacity(0.3),
                DeadTheme.Colors.cardBackground.opacity(0.6),
                DeadTheme.Colors.cardBackground.opacity(0.3)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white, .clear]),
                        startPoint: .init(x: phase - 0.5, y: 0.5),
                        endPoint: .init(x: phase + 0.5, y: 0.5)
                    )
                )
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1.5
            }
        }
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.1),
                            .clear
                        ]),
                        startPoint: .init(x: phase - 0.3, y: 0.5),
                        endPoint: .init(x: phase + 0.3, y: 0.5)
                    )
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
