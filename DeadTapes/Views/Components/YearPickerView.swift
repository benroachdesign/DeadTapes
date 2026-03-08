import SwiftUI

struct YearPickerView: View {
    @Binding var selectedYear: Int
    var onSelect: (Int) -> Void

    // 0 = "All Time Top" special value
    let allItems: [Int] = [0] + Array(1965...1995)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeadTheme.Spacing.sm) {
                    ForEach(allItems, id: \.self) { year in
                        if year == 0 {
                            TopPill(isSelected: selectedYear == 0)
                                .id(0)
                                .onTapGesture {
                                    withAnimation(DeadTheme.Animation.springy) {
                                        selectedYear = 0
                                        onSelect(0)
                                    }
                                }
                        } else {
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

// MARK: - Top Pill (All Time)

struct TopPill: View {
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 11))
            Text("Top")
                .font(isSelected ? DeadTheme.Typography.headline() : DeadTheme.Typography.body())
        }
        .foregroundStyle(isSelected ? DeadTheme.Colors.background : Color(hex: "FFD700"))
        .padding(.horizontal, DeadTheme.Spacing.lg)
        .padding(.vertical, DeadTheme.Spacing.sm)
        .background {
            if isSelected {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), DeadTheme.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 8, y: 2)
            } else {
                Capsule()
                    .fill(DeadTheme.Colors.cardBackground)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(DeadTheme.Animation.springy, value: isSelected)
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
