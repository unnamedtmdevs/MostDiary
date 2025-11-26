//  MainContainerView.swift
//  TimeDiary


import SwiftUI

struct MainContainerView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            if coordinator.isLoading {
                LoadingView()
            } else if coordinator.showServerCheck {
                ServerCheckView(coordinator: coordinator)
            } else if coordinator.showOnboarding {
                OnboardingContainerView(coordinator: coordinator)
            } else {
                MainTabView(selectedTab: $coordinator.selectedTab)
            }
        }
    }
}

struct OnboardingContainerView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Onboarding1View(onNext: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                proxy.scrollTo(1, anchor: .leading)
                            }
                            coordinator.nextOnboardingPage()
                        })
                        .frame(width: geometry.size.width)
                        .id(0)

                        Onboarding2View(onNext: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                proxy.scrollTo(2, anchor: .leading)
                            }
                            coordinator.nextOnboardingPage()
                        })
                        .frame(width: geometry.size.width)
                        .id(1)

                        Onboarding3View(onComplete: coordinator.completeOnboarding)
                        .frame(width: geometry.size.width)
                        .id(2)
                    }
                }
                .modifier(ScrollViewPagingModifier())
                .onChange(of: coordinator.currentOnboardingPage) { newPage in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        proxy.scrollTo(newPage, anchor: .leading)
                    }
                }
                .onAppear {
                    proxy.scrollTo(coordinator.currentOnboardingPage, anchor: .leading)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct ScrollViewPagingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.scrollTargetBehavior(.paging)
        } else {
            content
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView

            if selectedTab != .tracking {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView(selectedTab: $selectedTab)
        case .tracking:
            TrackingView(selectedTab: $selectedTab)
        case .categories:
            CategoriesView()
        case .history:
            HistoryView()
        case .analytics:
            AnalyticsView()
        }
    }
}
