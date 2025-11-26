//  CategoriesView.swift
//  TimeDiary


import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedCategory: Category?
    @State private var showingAddCategory = false
    @State private var categoryToDelete: Category?
    @State private var showingDeleteAlert = false

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
                headerSection
                    .id("header_\(themeManager.currentTheme)")
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)

                if viewModel.categories.isEmpty {
                    ScrollView(showsIndicators: false) {
                        emptyState
                            .id("empty_\(themeManager.currentTheme)")
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.bottom, AppSpacing.xl)
                    }
                } else {
                    categoriesList
                        .id("list_\(themeManager.currentTheme)")
                }
            }
            .background(
                GeometryReader { _ in
                    Color.clear
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categories")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent6, AppColors.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.accent1.opacity(0.5), radius: 10, x: 0, y: 0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Manage your activity categories")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Decorative element
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.accent1.opacity(0.3), AppColors.accent6.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)

                    Circle()
                        .fill(AppColors.accent1.opacity(0.2))
                        .frame(width: 60, height: 60)
                }
            }
        }
    }

    private var categoriesList: some View {
        VStack(spacing: 0) {
            // Add category button
            Button(action: {
                HapticsService.shared.impact(.medium)
                showingAddCategory = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Add New Category")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        colors: [AppColors.accent1, AppColors.accent6],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
            
            List {
                ForEach(viewModel.sortedCategories) { category in
                    CategoryDetailCardView(
                        category: category,
                        totalTime: viewModel.getTotalTime(for: category),
                        entryCount: viewModel.getEntryCount(for: category)
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticsService.shared.impact(.light)
                        selectedCategory = category
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            HapticsService.shared.impact(.medium)
                            categoryToDelete = category
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .modifier(ListBackgroundModifier())
            .padding(.bottom, 70)
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(
                category: category,
                onCategoryUpdated: {
                    viewModel.loadData()
                },
                onCategoryDeleted: {
                    viewModel.loadData()
                    selectedCategory = nil
                }
            )
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditView { newCategory in
                viewModel.addCategory(
                    name: newCategory.name,
                    iconName: newCategory.iconName,
                    colorHex: newCategory.colorHex
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary.opacity(0.5))

            Text("No categories yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("Create your first category to start tracking")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                HapticsService.shared.impact(.medium)
                showingAddCategory = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create Category")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    LinearGradient(
                        colors: [AppColors.accent1, AppColors.accent6],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: AppColors.accent1.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.top, AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditView { newCategory in
                viewModel.addCategory(
                    name: newCategory.name,
                    iconName: newCategory.iconName,
                    colorHex: newCategory.colorHex
                )
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    viewModel.deleteCategory(category)
                    categoryToDelete = nil
                }
            }
        } message: {
            if let category = categoryToDelete {
                Text("Are you sure you want to delete \"\(category.name)\"? All entries in this category will be removed. This action cannot be undone.")
            }
        }
    }
}

// Modifier to hide List background for iOS 15 compatibility
struct ListBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
        }
    }
}

