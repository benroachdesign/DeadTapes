import SwiftUI

struct CircularProgressSlider: View {
    @Binding var progress: Double
    var onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragAngle: Double = 0

    private let lineWidth: CGFloat = 6
    private let thumbSize: CGFloat = 24
    private let glowRadius: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = (size - thumbSize - lineWidth) / 2
            let center = CGPoint(x: size / 2, y: size / 2)

            ZStack {
                // Background track
                Circle()
                    .stroke(
                        DeadTheme.Colors.progressTrack,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: radius * 2, height: radius * 2)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(currentProgress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                DeadTheme.Colors.accent,
                                DeadTheme.Colors.psychPurple,
                                DeadTheme.Colors.psychPink,
                                DeadTheme.Colors.accent
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: DeadTheme.Colors.progressGlow, radius: isDragging ? glowRadius : 4)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: DeadTheme.Colors.accent.opacity(0.5), radius: isDragging ? 12 : 6)
                    .scaleEffect(isDragging ? 1.3 : 1.0)
                    .offset(x: radius * cos(CGFloat(thumbAngle)),
                            y: radius * sin(CGFloat(thumbAngle)))
                    .animation(DeadTheme.Animation.springy, value: isDragging)

                // Inner glow pulse
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DeadTheme.Colors.accent.opacity(isDragging ? 0.15 : 0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: radius * 0.3,
                            endRadius: radius * 0.8
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let vector = CGPoint(
                            x: value.location.x - center.x,
                            y: value.location.y - center.y
                        )
                        var angle = atan2(vector.y, vector.x) + .pi / 2
                        if angle < 0 { angle += .pi * 2 }
                        dragAngle = angle
                    }
                    .onEnded { _ in
                        isDragging = false
                        let newProgress = dragAngle / (.pi * 2)
                        onSeek(min(max(newProgress, 0), 1))
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var currentProgress: Double {
        isDragging ? dragAngle / (.pi * 2) : progress
    }

    private var thumbAngle: Double {
        let p = currentProgress
        return (p * .pi * 2) - (.pi / 2)
    }
}
