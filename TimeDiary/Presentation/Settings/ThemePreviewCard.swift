//  ThemePreviewCard.swift
//  TimeDiary


import SwiftUI

struct ThemePreviewCard: View {
    let theme: ColorTheme
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var previewColorScheme: ColorScheme {
        switch theme {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return systemColorScheme
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                // Preview
                ZStack {
                    // Background gradient
                    Group {
                        if theme == .light {
                            LinearGradient(
                                colors: [
                                    Color(hex: "F5F5F5"),
                                    Color(hex: "E8E8E8"),
                                    Color(hex: "F5F5F5")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else if theme == .dark {
                            LinearGradient(
                                colors: [
                                    Color(hex: "1a1a2e"),
                                    Color(hex: "16213e"),
                                    Color(hex: "1a1a2e")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            // System theme - use current system color scheme
                            LinearGradient(
                                colors: systemColorScheme == .light ? [
                                    Color(hex: "F5F5F5"),
                                    Color(hex: "E8E8E8"),
                                    Color(hex: "F5F5F5")
                                ] : [
                                    Color(hex: "1a1a2e"),
                                    Color(hex: "16213e"),
                                    Color(hex: "1a1a2e")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                    
                    // Card preview
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme == .light ? Color.white.opacity(0.9) : (theme == .dark ? Color.white.opacity(0.05) : (systemColorScheme == .light ? Color.white.opacity(0.9) : Color.white.opacity(0.05))))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "6A1B9A").opacity(0.3))
                            .frame(height: 8)
                    }
                    .padding(6)
                }
                .frame(height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? AppColors.accent1 : AppColors.borderPrimary.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                
                Text(theme.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

