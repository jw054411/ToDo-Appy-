import SwiftUI

/// LoadingSpinner - Animated loading indicator
struct LoadingSpinner: View {
    // MARK: - Properties

    let size: SpinnerSize
    let color: Color

    // MARK: - State

    @State private var isAnimating = false

    // MARK: - Initializer

    init(size: SpinnerSize = .medium, color: Color = AppColors.accentBlue) {
        self.size = size
        self.color = color
    }

    // MARK: - Body

    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.system(size: size.iconSize, weight: .medium))
            .foregroundColor(color)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Spinner Size

extension LoadingSpinner {
    enum SpinnerSize {
        case small
        case medium
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 40
            }
        }
    }
}

// MARK: - Fullscreen Loading View

struct LoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            LoadingSpinner(size: .large)

            if let message = message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Pull to Refresh Indicator

struct PullToRefreshIndicator: View {
    @Binding var isRefreshing: Bool

    var body: some View {
        HStack {
            Spacer()

            if isRefreshing {
                LoadingSpinner(size: .small)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Preview

#Preview("LoadingSpinner") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Loading Spinners")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Sizes
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Sizes")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: AppSpacing.xl) {
                        VStack {
                            LoadingSpinner(size: .small)
                            Text("Small")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        VStack {
                            LoadingSpinner(size: .medium)
                            Text("Medium")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        VStack {
                            LoadingSpinner(size: .large)
                            Text("Large")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                // Colors
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Colors")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: AppSpacing.lg) {
                        LoadingSpinner(color: AppColors.accentBlue)
                        LoadingSpinner(color: AppColors.accentPurple)
                        LoadingSpinner(color: AppColors.accentGreen)
                        LoadingSpinner(color: AppColors.accentOrange)
                        LoadingSpinner(color: AppColors.accentRed)
                    }
                }

                // In Card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("In Card")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    AppCard {
                        HStack {
                            LoadingSpinner(size: .small)
                            Text("Loading data...")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                // Pull to Refresh
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Pull to Refresh")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    PullToRefreshIndicator(isRefreshing: .constant(true))
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(AppCornerRadius.md)
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}

#Preview("LoadingView") {
    LoadingView(message: "Syncing your tasks...")
}
