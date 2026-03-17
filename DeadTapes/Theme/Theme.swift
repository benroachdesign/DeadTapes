import SwiftUI

// MARK: - Design Tokens

enum DeadTheme {

    // MARK: Colors

    enum Colors {
        // Backgrounds
        static let background = Color(hex: "0A0A0F")
        static let cardBackground = Color(hex: "151520")
        static let elevatedBackground = Color(hex: "1C1C2E")
        static let surfaceBackground = Color(hex: "12121A")

        // Primary accent — warm amber/gold
        static let accent = Color(hex: "E8A849")
        static let accentSecondary = Color(hex: "D4763C")

        // Psychedelic palette
        static let psychPurple = Color(hex: "8B5CF6")
        static let psychPink = Color(hex: "EC4899")
        static let psychBlue = Color(hex: "3B82F6")
        static let psychTeal = Color(hex: "14B8A6")
        static let psychRose = Color(hex: "F43F5E")
        static let psychOrange = Color(hex: "F97316")

        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "9CA3AF")
        static let textTertiary = Color(hex: "6B7280")

        // Source badges
        static let sbd = Color(hex: "10B981")
        static let aud = Color(hex: "F59E0B")
        static let matrix = Color(hex: "8B5CF6")

        // Player
        static let progressTrack = Color(hex: "2A2A3E")
        static let progressGlow = Color(hex: "E8A849").opacity(0.6)
    }

    // MARK: Gradients

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Colors.accent, Colors.accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let psychedelic = LinearGradient(
            colors: [Colors.psychPurple, Colors.psychPink, Colors.psychOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let seventies = LinearGradient(
            colors: [
                Color(hex: "B45309"),
                Color(hex: "D97706"),
                Color(hex: "92400E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let eighties = LinearGradient(
            colors: [
                Color(hex: "7C3AED"),
                Color(hex: "EC4899"),
                Color(hex: "06B6D4")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardGlow = LinearGradient(
            colors: [
                Colors.accent.opacity(0.15),
                Colors.psychPurple.opacity(0.08),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let nowPlayingBackground = LinearGradient(
            colors: [
                Colors.psychPurple.opacity(0.4),
                Colors.background,
                Colors.psychPink.opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Typography

    enum Typography {
        static func largeTitle() -> Font {
            .system(size: 34, weight: .bold, design: .rounded)
        }

        static func title() -> Font {
            .system(size: 24, weight: .bold, design: .rounded)
        }

        static func title2() -> Font {
            .system(size: 20, weight: .semibold, design: .rounded)
        }

        static func headline() -> Font {
            .system(size: 17, weight: .semibold, design: .rounded)
        }

        static func body() -> Font {
            .system(size: 15, weight: .regular, design: .rounded)
        }

        static func caption() -> Font {
            .system(size: 13, weight: .medium, design: .rounded)
        }

        static func mono() -> Font {
            .system(size: 13, weight: .medium, design: .monospaced)
        }

        static func monoSmall() -> Font {
            .system(size: 11, weight: .regular, design: .monospaced)
        }
    }

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let hero: CGFloat = 48
    }

    // MARK: Corner Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: Animation

    enum Animation {
        static let springy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.6)
        static let gradient = SwiftUI.Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
    }

    // MARK: Era Palette

    /// Single source of truth for era-based color arrays.
    /// Used by `eraGradient(for:)` and `NowPlayingFullView` background.
    static func eraColors(for year: Int) -> [Color] {
        switch year {
        case ...1969:
            return [Color(hex: "DC2626"), Color(hex: "F97316"), Color(hex: "FBBF24")]
        case 1970...1974:
            return [Color(hex: "B45309"), Color(hex: "D97706"), Color(hex: "92400E")]
        case 1975...1979:
            return [Color(hex: "D97706"), Color(hex: "B45309"), Color(hex: "78350F")]
        case 1980...1989:
            return [Color(hex: "7C3AED"), Color(hex: "EC4899"), Color(hex: "06B6D4")]
        default:
            return [Colors.psychPurple, Colors.psychPink, Colors.psychOrange]
        }
    }

    /// Era-appropriate gradient for text/badges.
    static func eraGradient(for year: Int) -> LinearGradient {
        LinearGradient(
            colors: eraColors(for: year),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
