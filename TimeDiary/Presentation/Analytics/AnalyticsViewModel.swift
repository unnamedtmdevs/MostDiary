//  AnalyticsViewModel.swift
//  TimeDiary


import SwiftUI

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .today
    @Published var analyticsData: AnalyticsData?
    @Published var showingDatePicker = false

    private let analyticsService = AnalyticsService.shared

    init() {
        loadAnalytics()
    }

    func loadAnalytics() {
        analyticsData = analyticsService.getAnalytics(for: selectedPeriod)
    }

    func selectPeriod(_ period: TimePeriod) {
        selectedPeriod = period
        loadAnalytics()
    }

    func selectCustomRange(start: Date, end: Date) {
        selectedPeriod = .custom(start: start, end: end)
        loadAnalytics()
    }

    var totalTime: String {
        analyticsData?.formattedTotalTime ?? "0m"
    }

    var averageTimePerDay: String {
        analyticsData?.formattedAverageTime ?? "0m"
    }

    var numberOfEntries: Int {
        analyticsData?.numberOfEntries ?? 0
    }

    var mostActiveCategory: String {
        analyticsData?.mostActiveCategory?.categoryName ?? "None"
    }

    var categoryBreakdown: [CategoryStatistic] {
        analyticsData?.categoryBreakdown ?? []
    }

    var dailyBreakdown: [DailyStatistic] {
        analyticsData?.dailyBreakdown ?? []
    }

    var workRestRatio: String {
        guard let ratio = analyticsData?.workRestRatio, ratio > 0 else {
            return "N/A"
        }
        return String(format: "%.1f:1", ratio)
    }

    var balanceIndicator: (text: String, color: Color) {
        guard let ratio = analyticsData?.workRestRatio, ratio > 0 else {
            return ("No data", AppColors.textTertiary)
        }

        if ratio < 0.5 {
            return ("Well rested", AppColors.success)
        } else if ratio < 1.5 {
            return ("Balanced", AppColors.accent2)
        } else if ratio < 2.5 {
            return ("Work focused", AppColors.warning)
        } else {
            return ("Need rest", AppColors.error)
        }
    }

    var hasData: Bool {
        (analyticsData?.numberOfEntries ?? 0) > 0
    }

    var topCategories: [CategoryStatistic] {
        Array(categoryBreakdown.prefix(5))
    }

    func getCategoryColor(_ categoryColorHex: String) -> Color {
        Color(hex: categoryColorHex)
    }
}
