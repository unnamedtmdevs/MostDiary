//  EntryNoteEditView.swift
//  TimeDiary


import SwiftUI

struct EntryNoteEditView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let entry: TimeEntry
    let onSave: (String?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var notesText: String
    @FocusState private var isFocused: Bool
    
    init(entry: TimeEntry, onSave: @escaping (String?) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _notesText = State(initialValue: entry.notes ?? "")
    }
    
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
            
            VStack(spacing: 0) {
                // Header
                headerSection
                    .id("header_\(themeManager.currentTheme)")
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.lg)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        // Entry info card
                        entryInfoCard
                            .id("info_\(themeManager.currentTheme)")
                        
                        // Notes editor
                        notesEditor
                            .id("editor_\(themeManager.currentTheme)")
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Close keyboard when tapping outside
                        isFocused = false
                    }
            )
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                    .foregroundColor(AppColors.accent1)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                HapticsService.shared.impact(.light)
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.backgroundCard,
                            AppColors.backgroundCard.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
            
            Button(action: {
                HapticsService.shared.impact(.light)
                let trimmedNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
                onSave(trimmedNotes.isEmpty ? nil : trimmedNotes)
                dismiss()
            }) {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [AppColors.accent1, AppColors.accent2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppColors.accent1.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var entryInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(entry.categoryName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(entry.formattedDuration)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.accent1)
            }
            
            Text(entry.formattedTimeRange)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundCard,
                    AppColors.backgroundCard.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.accent1.opacity(0.3), AppColors.accent2.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
    
    private var notesEditor: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Notes")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            ZStack(alignment: .topLeading) {
                if notesText.isEmpty {
                    Text("Add your notes here...")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $notesText)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .focused($isFocused)
                    .frame(minHeight: 200)
                    .padding(12)
                    .modifier(TextEditorBackgroundModifier())
            }
            .background(
                LinearGradient(
                    colors: [
                        AppColors.backgroundCard,
                        AppColors.backgroundCard.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isFocused ?
                        LinearGradient(
                            colors: [AppColors.accent1.opacity(0.5), AppColors.accent2.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [AppColors.borderPrimary.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
        }
    }
}

// Modifier to hide TextEditor background for iOS 15 compatibility
struct TextEditorBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                }
        }
    }
}

