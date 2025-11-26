//  Onboarding2View.swift
//  TimeDiary


import SwiftUI

struct Onboarding2View: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let onNext: () -> Void
    @State private var iconScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    AppColors.backgroundPrimary,
                    AppColors.backgroundSecondary,
                    AppColors.backgroundPrimary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.accent2.opacity(0.25),
                                AppColors.accent3.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(x: -140, y: -320)
                    .blur(radius: 45)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.accent6.opacity(0.2),
                                AppColors.accent1.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 220, height: 220)
                    .offset(x: 140, y: 380)
                    .blur(radius: 35)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    Spacer()
                        .frame(height: 60)

                    // Icon with gradient
                ZStack {
                    // Pulsing background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.accent2.opacity(0.3),
                                    AppColors.accent3.opacity(0.2),
                                    AppColors.accent6.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 25)
                    
                    // Main icon container
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.backgroundCard,
                                        AppColors.backgroundCard.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .shadow(color: AppColors.accent2.opacity(0.4), radius: 25, x: 0, y: 12)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppColors.accent2.opacity(0.5),
                                                AppColors.accent3.opacity(0.3),
                                                AppColors.accent6.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 65, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accent2, AppColors.accent3, AppColors.accent6],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(iconScale)

                // Title with gradient
                Text("How It Works")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accent2, AppColors.accent3, AppColors.accent6],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: AppColors.accent2.opacity(0.5), radius: 10, x: 0, y: 0)
                    .padding(.horizontal, AppSpacing.xl)

                // Features
                VStack(spacing: AppSpacing.md) {
                    FeatureRow(
                        icon: "clock.fill",
                        text: "Start timer for any activity",
                        color: AppColors.accent1,
                        index: 0
                    )
                    FeatureRow(
                        icon: "folder.fill",
                        text: "Organize by categories",
                        color: AppColors.accent2,
                        index: 1
                    )
                    FeatureRow(
                        icon: "chart.bar.fill",
                        text: "View analytics and insights",
                        color: AppColors.accent6,
                        index: 2
                    )
                }
                .padding(.horizontal, AppSpacing.xl)

                Spacer()

                // Button with gradient
                Button(action: {
                    HapticsService.shared.impact(.medium)
                    onNext()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [AppColors.accent2, AppColors.accent3, AppColors.accent6],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: AppColors.accent2.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
                    
                    Spacer()
                        .frame(height: 60)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
        }
        .id("onboarding2_\(themeManager.currentTheme)")
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                iconScale = 1.0
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    let index: Int
    @State private var appearOffset: CGFloat = 50
    @State private var appearOpacity: Double = 0

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.top, 2)

            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundCard,
                    AppColors.backgroundCard.opacity(0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.3), AppColors.borderPrimary.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        .offset(x: appearOffset)
        .opacity(appearOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                appearOffset = 0
                appearOpacity = 1.0
            }
        }
    }
}
