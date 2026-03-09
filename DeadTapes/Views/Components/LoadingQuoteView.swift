import SwiftUI

// MARK: - Loading Quotes

struct LoadingQuote {
    let lyric: String
    let song: String

    static let quotes: [LoadingQuote] = [
        // Ripple
        LoadingQuote(lyric: "If my app did load, with the glow of sunshine…", song: "Ripple"),
        // Jack Straw
        LoadingQuote(lyric: "Jack Straw from Wichita, cut his load time down…", song: "Jack Straw"),
        // Truckin'
        LoadingQuote(lyric: "Loadin'… I got my chips cashed in…", song: "Truckin'"),
        // Casey Jones
        LoadingQuote(lyric: "Drivin' that train, high on buffering…", song: "Casey Jones"),
        // Friend of the Devil
        LoadingQuote(lyric: "I set out loading, I was trailed by twenty GB...", song: "Friend of the Devil"),
        // Fire on the Mountain
        LoadingQuote(lyric: "Long distance loader, what you standing there for?", song: "Fire on the Mountain"),
        // Touch of Grey
        LoadingQuote(lyric: "We will get by… we will survive this load time…", song: "Touch of Grey"),
        // Sugar Magnolia
        LoadingQuote(lyric: "Sugar Magnolia, streams are loading, apps all empty and I don't care", song: "Sugar Magnolia"),
        // Uncle John's Band
        LoadingQuote(lyric: "Come hear Uncle John's Band, by the server side…", song: "Uncle John's Band"),
        // The Music Never Stopped
        LoadingQuote(lyric: "The loading never stopped…", song: "The Music Never Stopped"),
        // Eyes of the World
        LoadingQuote(lyric: "Right outside this lazy summer loading…", song: "Eyes of the World"),
        // Box of Rain
        LoadingQuote(lyric: "Look out of any window, any morning, any evening, any load time…", song: "Box of Rain"),
        // Bertha
        LoadingQuote(lyric: "I had a hard run, runnin' from your buffer...", song: "Bertha"),
        // Estimated Prophet
        LoadingQuote(lyric: "My app loading any day, don't worry 'bout me, no", song: "Estimated Prophet"),
        // China Cat Sunflower
        LoadingQuote(lyric: "Load for a while with the China Cat Sunflower", song: "China Cat Sunflower"),
        // Althea
        LoadingQuote(lyric: "There are things you can replace, and buffers you cannot…", song: "Althea"),
        // Deal
        LoadingQuote(lyric: "Don't you let that data go, no, no, no…", song: "Deal"),
        // St. Stephen
        LoadingQuote(lyric: "St. Stephen with a rose, in and out of the app he loads", song: "St. Stephen"),
        // Not Fade Away
        LoadingQuote(lyric: "You know my load will not fade away...", song: "Not Fade Away"),
    ]

    static func random() -> LoadingQuote {
        quotes.randomElement() ?? quotes[0]
    }
}

// MARK: - Loading Quote View

struct LoadingQuoteView: View {
    @State private var quote = LoadingQuote.random()
    @State private var opacity: Double = 0
    @State private var quoteTimer: Timer?

    let rotationInterval: TimeInterval

    init(rotationInterval: TimeInterval = 4.0) {
        self.rotationInterval = rotationInterval
    }

    var body: some View {
        VStack(spacing: DeadTheme.Spacing.md) {
            // Animated dots
            LoadingDots()

            // Quote
            VStack(spacing: DeadTheme.Spacing.xs) {
                Text("\"" + quote.lyric + "\"")
                    .font(DeadTheme.Typography.headline())
                    .foregroundStyle(DeadTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .italic()
                    .lineLimit(3)

                Text("— \(quote.song)")
                    .font(DeadTheme.Typography.monoSmall())
                    .foregroundStyle(DeadTheme.Colors.textTertiary)
            }
            .opacity(opacity)
            .padding(.horizontal, DeadTheme.Spacing.xl)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
            startRotation()
        }
        .onDisappear {
            quoteTimer?.invalidate()
            quoteTimer = nil
        }
    }

    private func startRotation() {
        quoteTimer = Timer.scheduledTimer(withTimeInterval: rotationInterval, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                quote = LoadingQuote.random()
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
            }
        }
    }
}

// MARK: - Loading Dots Animation

struct LoadingDots: View {
    @State private var activeDot = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(DeadTheme.Colors.accent)
                    .frame(width: 6, height: 6)
                    .opacity(activeDot == i ? 1.0 : 0.25)
                    .scaleEffect(activeDot == i ? 1.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: activeDot
                    )
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                activeDot = (activeDot + 1) % 3
            }
        }
    }
}
