import SwiftUI

struct YearPickerView: View {
    @Binding var selectedYear: Int
    var onSelect: (Int) -> Void

    let years = Array(1965...1995)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeadTheme.Spacing.sm) {
                    ForEach(years, id: \.self) { year in
                        YearPill(
                            year: year,
                            isSelected: year == selectedYear
                        )
                        .id(year)
                        .onTapGesture {
                            withAnimation(DeadTheme.Animation.springy) {
                                selectedYear = year
                                onSelect(year)
                            }
                        }
                    }
                }
                .padding(.horizontal, DeadTheme.Spacing.lg)
            }
            .onAppear {
                proxy.scrollTo(selectedYear, anchor: .center)
            }
            .onChange(of: selectedYear) { _, newYear in
                withAnimation(DeadTheme.Animation.smooth) {
                    proxy.scrollTo(newYear, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Year Pill

struct YearPill: View {
    let year: Int
    let isSelected: Bool

    var body: some View {
        Text(String(year))
            .font(isSelected ? DeadTheme.Typography.headline() : DeadTheme.Typography.body())
            .foregroundStyle(isSelected ? DeadTheme.Colors.background : DeadTheme.Colors.textSecondary)
            .padding(.horizontal, DeadTheme.Spacing.lg)
            .padding(.vertical, DeadTheme.Spacing.sm)
            .background {
                if isSelected {
                    Capsule()
                        .fill(DeadTheme.Colors.accent)
                        .shadow(color: DeadTheme.Colors.accent.opacity(0.4), radius: 8, y: 2)
                } else {
                    Capsule()
                        .fill(DeadTheme.Colors.cardBackground)
                        .overlay(
                            Capsule()
                                .strokeBorder(DeadTheme.Colors.textTertiary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(DeadTheme.Animation.springy, value: isSelected)
    }
}
