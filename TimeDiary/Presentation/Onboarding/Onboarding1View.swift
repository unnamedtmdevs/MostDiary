//  Onboarding1View.swift
//  TimeDiary


import SwiftUI

struct Onboarding1View: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let onNext: () -> Void
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = 0

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
                                AppColors.accent1.opacity(0.3),
                                AppColors.accent6.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: -300)
                    .blur(radius: 50)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.accent2.opacity(0.2),
                                AppColors.accent3.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 250, height: 250)
                    .offset(x: 150, y: 400)
                    .blur(radius: 40)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    Spacer()
                        .frame(height: 60)

                    // Icon with gradient and animation
                ZStack {
                    // Pulsing background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.accent1.opacity(0.3),
                                    AppColors.accent6.opacity(0.2),
                                    AppColors.accent2.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                    
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
                            .frame(width: 160, height: 160)
                            .shadow(color: AppColors.accent1.opacity(0.4), radius: 30, x: 0, y: 15)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppColors.accent1.opacity(0.5),
                                                AppColors.accent6.opacity(0.3),
                                                AppColors.accent2.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        Image(systemName: "clock.badge.checkmark.fill")
                            .font(.system(size: 70, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(iconRotation))
                    }
                }
                .scaleEffect(iconScale)

                // Title with gradient
                Text("Welcome to MostDiary")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)
                    .padding(.horizontal, AppSpacing.xl)

                // Description
                Text("Track how you spend your time and\noptimize your lifestyle")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                    .lineSpacing(4)

                Spacer()

                // Button with gradient
                Button(action: {
                    HapticsService.shared.impact(.medium)
                    onNext()
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
                    
                    Spacer()
                        .frame(height: 60)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
        }
        .id("onboarding1_\(themeManager.currentTheme)")
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
        }
    }
}
