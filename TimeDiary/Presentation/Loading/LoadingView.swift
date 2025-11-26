//  LoadingView.swift
//  TimeDiary


import SwiftUI

struct LoadingView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var isRotating = false
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var pulseScale: CGFloat = 1.0

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
                                AppColors.accent1.opacity(0.2),
                                AppColors.accent6.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: -300)
                    .blur(radius: 40)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.accent2.opacity(0.15),
                                AppColors.accent3.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 250, height: 250)
                    .offset(x: 150, y: 400)
                    .blur(radius: 30)
            }

            VStack(spacing: AppSpacing.xl) {
                // Icon with gradient and rotation
                ZStack {
                    // Pulsing background circle
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
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulseScale)
                        .blur(radius: 20)
                    
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
                            .frame(width: 120, height: 120)
                            .shadow(color: AppColors.accent1.opacity(0.4), radius: 20, x: 0, y: 10)
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
                                        lineWidth: 2
                                    )
                            )
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(isRotating ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                value: isRotating
                            )
                    }
                }
                .scaleEffect(scale)

                // App name with gradient
                Text("MostDiary")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)

                // Subtitle
                Text("Track Your Time")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .opacity(opacity)
        }
        .id("loading_\(themeManager.currentTheme)")
        .onAppear {
            isRotating = true
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
                scale = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
        }
    }
}
