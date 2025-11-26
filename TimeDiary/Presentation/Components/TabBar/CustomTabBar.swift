//  CustomTabBar.swift
//  TimeDiary


import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case tracking
    case categories
    case history
    case analytics

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .tracking:
            return "clock.fill"
        case .categories:
            return "folder.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .analytics:
            return "chart.bar.fill"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .tracking:
            return "Track"
        case .categories:
            return "Categories"
        case .history:
            return "History"
        case .analytics:
            return "Analytics"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @ObservedObject private var themeManager = ThemeManager.shared
    @Namespace private var animation

    // Tabs visible in tab bar (excluding tracking)
    private var visibleTabs: [TabItem] {
        TabItem.allCases.filter { $0 != .tracking }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(visibleTabs, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    HapticsService.shared.impact(.light)
                }
                .id("\(tab)_\(themeManager.currentTheme)")
            }
        }
        .id("tabbar_\(themeManager.currentTheme)")
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.backgroundCard.opacity(0.9),
                            AppColors.backgroundSecondary.opacity(0.7),
                            AppColors.backgroundCard.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: -5)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.accent1.opacity(0.3),
                                    AppColors.accent6.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.accent1,
                                        AppColors.accent6.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 44)
                            .shadow(color: AppColors.accent1.opacity(0.6), radius: 12, x: 0, y: 4)
                            .matchedGeometryEffect(id: "tab_background", in: animation)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : AppColors.textTertiary)
                        .frame(width: 60, height: 44)
                }

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.accent1 : AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
