//  CalendarView.swift
//  TimeDiary


import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date?
    let entries: [TimeEntry]
    @ObservedObject private var themeManager = ThemeManager.shared
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date?>, entries: [TimeEntry]) {
        self._selectedDate = selectedDate
        self.entries = entries
        dateFormatter.dateFormat = "MMMM yyyy"
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Month header with navigation
            monthHeader
            
            // Calendar grid
            calendarGrid
        }
        .padding(AppSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundCard,
                    AppColors.backgroundCard.opacity(0.6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: {
                HapticsService.shared.impact(.light)
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.accent1.opacity(0.2),
                                AppColors.accent1.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: currentMonth))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: {
                HapticsService.shared.impact(.light)
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.accent1.opacity(0.2),
                                AppColors.accent1.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
            }
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: AppSpacing.sm) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppSpacing.xs) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        calendarDayCell(date: date)
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
    }
    
    private func calendarDayCell(date: Date) -> some View {
        let hasEntries = hasEntries(for: date)
        let isSelected = selectedDate?.isSameDay(as: date) ?? false
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        
        return Button(action: {
            HapticsService.shared.impact(.light)
            if isSelected {
                selectedDate = nil
            } else {
                selectedDate = date
            }
        }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(
                        isSelected ? AppColors.textPrimary :
                        (isCurrentMonth ? AppColors.textPrimary : AppColors.textTertiary)
                    )
                
                if hasEntries {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.6), AppColors.accent6.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 4, height: 4)
                } else {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(width: 44, height: 44)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [AppColors.accent1, AppColors.accent6],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else if isToday {
                        LinearGradient(
                            colors: [
                                AppColors.accent1.opacity(0.2),
                                AppColors.accent1.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.clear :
                        (isToday ? AppColors.accent1.opacity(0.4) : Color.clear),
                        lineWidth: isToday ? 1.5 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        guard let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
            return []
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let startingSpaces = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: startingSpaces)
        
        var currentDate = firstDayOfMonth
        while calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Fill remaining spaces to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasEntries(for date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.startTime, inSameDayAs: date)
        }
    }
}

