//  CategoryEditView.swift
//  TimeDiary


import SwiftUI

struct CategoryEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CategoryEditViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    let onSave: (Category) -> Void
    
    init(category: Category? = nil, onSave: @escaping (Category) -> Void) {
        _viewModel = StateObject(wrappedValue: CategoryEditViewModel(category: category))
        self.onSave = onSave
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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    headerSection
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.lg)
                    
                    // Name input
                    nameSection
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Icon selection
                    iconSelectionSection
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Color selection
                    colorSelectionSection
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Save button
                    saveButton
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Close keyboard when tapping outside
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
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
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
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
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.4), AppColors.accent6.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
            
            Text(viewModel.isEditing ? "Edit Category" : "New Category")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            // Placeholder for balance
            Color.clear
                .frame(width: 100, height: 40)
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Category Name")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            TextField("Enter category name", text: $viewModel.categoryName)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .submitLabel(.done)
                .onSubmit {
                    // Close keyboard on Return/Done
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(AppSpacing.md)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.backgroundInput,
                            AppColors.backgroundInput.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.borderPrimary.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Select Icon")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: AppSpacing.md) {
                ForEach(viewModel.availableIcons, id: \.self) { icon in
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        viewModel.selectedIcon = icon
                    }) {
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.selectedIcon == icon ? AppColors.textPrimary : AppColors.textSecondary)
                            .frame(width: 50, height: 50)
                            .background(
                                viewModel.selectedIcon == icon ?
                                LinearGradient(
                                    colors: [viewModel.selectedColor, viewModel.selectedColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [AppColors.backgroundCard, AppColors.backgroundCard.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        viewModel.selectedIcon == icon ?
                                        viewModel.selectedColor.opacity(0.5) :
                                        AppColors.borderPrimary.opacity(0.3),
                                        lineWidth: viewModel.selectedIcon == icon ? 2 : 1
                                    )
                            )
                            .shadow(
                                color: viewModel.selectedIcon == icon ? viewModel.selectedColor.opacity(0.3) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                }
            }
        }
    }
    
    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Select Color")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: AppSpacing.md) {
                ForEach(viewModel.availableColors, id: \.self) { color in
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        viewModel.selectedColorHex = color
                    }) {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(
                                        viewModel.selectedColorHex == color ?
                                        AppColors.textPrimary :
                                        Color.clear,
                                        lineWidth: 3
                                    )
                            )
                            .overlay(
                                Group {
                                    if viewModel.selectedColorHex == color {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                            .shadow(
                                color: viewModel.selectedColorHex == color ? Color(hex: color).opacity(0.5) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            HapticsService.shared.impact(.medium)
            if viewModel.isValid {
                let category = viewModel.createCategory()
                onSave(category)
                dismiss()
            }
        }) {
            Text(viewModel.isEditing ? "Save Changes" : "Create Category")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        colors: viewModel.isValid ? [AppColors.accent1, AppColors.accent6] : [AppColors.accent1.opacity(0.5), AppColors.accent6.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .disabled(!viewModel.isValid)
    }
}

@MainActor
final class CategoryEditViewModel: ObservableObject {
    @Published var categoryName: String = ""
    @Published var selectedIcon: String = "star.fill"
    @Published var selectedColorHex: String = "6A1B9A"
    
    let isEditing: Bool
    private let originalCategory: Category?
    
    let availableIcons = [
        "briefcase.fill", "bed.double.fill", "figure.run", "book.fill",
        "person.2.fill", "moon.fill", "paintbrush.fill", "square.grid.2x2.fill",
        "heart.fill", "gamecontroller.fill", "music.note", "camera.fill",
        "car.fill", "airplane", "bicycle", "cart.fill",
        "house.fill", "building.2.fill", "leaf.fill", "flame.fill",
        "star.fill", "bolt.fill", "trophy.fill", "gift.fill"
    ]
    
    let availableColors = [
        "6A1B9A", "43A047", "FF5722", "E91E63",
        "546E7A", "2196F3", "FF9800", "9C27B0",
        "00BCD4", "4CAF50", "F44336", "3F51B5"
    ]
    
    var selectedColor: Color {
        Color(hex: selectedColorHex)
    }
    
    var isValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(category: Category? = nil) {
        self.originalCategory = category
        self.isEditing = category != nil
        
        if let category = category {
            self.categoryName = category.name
            self.selectedIcon = category.iconName
            self.selectedColorHex = category.colorHex
        }
    }
    
    func createCategory() -> Category {
        if let original = originalCategory {
            // Update existing category
            return Category(
                id: original.id,
                name: categoryName.trimmingCharacters(in: .whitespaces),
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                isDefault: original.isDefault,
                createdAt: original.createdAt,
                lastUsedAt: original.lastUsedAt
            )
        } else {
            // Create new category
            return Category(
                name: categoryName.trimmingCharacters(in: .whitespaces),
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                isDefault: false
            )
        }
    }
}

