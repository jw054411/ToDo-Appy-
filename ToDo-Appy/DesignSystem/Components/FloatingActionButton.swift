import SwiftUI

/// FloatingActionButton - Circular floating action button for primary actions
struct FloatingActionButton: View {
    // MARK: - Properties

    let icon: String
    let color: Color
    let size: FABSize
    let action: () -> Void

    // MARK: - State

    @State private var isPressed = false

    // MARK: - Initializer

    init(
        icon: String = "plus",
        color: Color = AppColors.accentBlue,
        size: FABSize = .regular,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            AppHaptics.medium()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size.diameter, height: size.diameter)
                    .shadowStrong()

                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(AppAnimations.springBouncy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - FAB Size

extension FloatingActionButton {
    enum FABSize {
        case small
        case regular
        case large

        var diameter: CGFloat {
            switch self {
            case .small: return 44
            case .regular: return 56
            case .large: return 72
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .regular: return 24
            case .large: return 32
            }
        }
    }
}

// MARK: - Extended FAB

struct ExtendedFAB: View {
    // MARK: - Properties

    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    // MARK: - State

    @State private var isPressed = false

    // MARK: - Initializer

    init(
        icon: String = "plus",
        title: String,
        color: Color = AppColors.accentBlue,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            AppHaptics.medium()
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(title)
                    .font(AppTypography.bodyBold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(color)
            .cornerRadius(AppCornerRadius.circle)
            .shadowStrong()
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppAnimations.springBouncy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - FAB Menu (Speed Dial)

struct FABMenu: View {
    // MARK: - Properties

    let mainIcon: String
    let mainColor: Color
    let items: [FABMenuItem]

    // MARK: - State

    @State private var isExpanded = false

    // MARK: - Initializer

    init(
        mainIcon: String = "plus",
        mainColor: Color = AppColors.accentBlue,
        items: [FABMenuItem]
    ) {
        self.mainIcon = mainIcon
        self.mainColor = mainColor
        self.items = items
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Overlay
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(AppAnimations.springSmooth) {
                            isExpanded = false
                        }
                    }
            }

            VStack(alignment: .trailing, spacing: AppSpacing.md) {
                // Menu Items
                if isExpanded {
                    ForEach(items.indices, id: \.self) { index in
                        HStack(spacing: AppSpacing.md) {
                            Text(items[index].label)
                                .font(AppTypography.bodyBold)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(AppCornerRadius.sm)
                                .shadowMedium()

                            FloatingActionButton(
                                icon: items[index].icon,
                                color: items[index].color,
                                size: .small
                            ) {
                                withAnimation(AppAnimations.springSmooth) {
                                    isExpanded = false
                                }
                                items[index].action()
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }

                // Main FAB
                FloatingActionButton(
                    icon: isExpanded ? "xmark" : mainIcon,
                    color: mainColor
                ) {
                    withAnimation(AppAnimations.springSmooth) {
                        isExpanded.toggle()
                    }
                }
                .rotationEffect(.degrees(isExpanded ? 135 : 0))
            }
        }
    }
}

// MARK: - FAB Menu Item

struct FABMenuItem {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
}

// MARK: - Preview

#Preview("FloatingActionButton") {
    ZStack(alignment: .bottomTrailing) {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                Text("Floating Action Buttons")
                    .font(AppTypography.title1)
                    .foregroundColor(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Sizes
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Sizes")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: AppSpacing.xl) {
                            VStack(spacing: AppSpacing.sm) {
                                FloatingActionButton(size: .small) {
                                    print("Small FAB tapped")
                                }
                                Text("Small")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            VStack(spacing: AppSpacing.sm) {
                                FloatingActionButton(size: .regular) {
                                    print("Regular FAB tapped")
                                }
                                Text("Regular")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            VStack(spacing: AppSpacing.sm) {
                                FloatingActionButton(size: .large) {
                                    print("Large FAB tapped")
                                }
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
                            FloatingActionButton(color: AppColors.accentBlue) {
                                print("Blue FAB")
                            }

                            FloatingActionButton(color: AppColors.accentPurple) {
                                print("Purple FAB")
                            }

                            FloatingActionButton(color: AppColors.accentGreen) {
                                print("Green FAB")
                            }

                            FloatingActionButton(color: AppColors.accentOrange) {
                                print("Orange FAB")
                            }
                        }
                    }

                    // Icons
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Icons")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: AppSpacing.lg) {
                            FloatingActionButton(icon: "plus") {
                                print("Plus")
                            }

                            FloatingActionButton(icon: "pencil") {
                                print("Edit")
                            }

                            FloatingActionButton(icon: "camera.fill") {
                                print("Camera")
                            }

                            FloatingActionButton(icon: "mic.fill") {
                                print("Mic")
                            }
                        }
                    }

                    // Extended FAB
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Extended FAB")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        ExtendedFAB(
                            icon: "plus.circle.fill",
                            title: "Create New Task"
                        ) {
                            print("Extended FAB tapped")
                        }
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AppColors.background)

        // Positioned FAB
        FloatingActionButton {
            print("Bottom-right FAB tapped")
        }
        .padding(AppSpacing.lg)
    }
}

#Preview("FAB Menu") {
    ZStack(alignment: .bottomTrailing) {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(0..<10) { index in
                    AppCard {
                        Text("Item \(index + 1)")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AppColors.background)

        FABMenu(
            items: [
                FABMenuItem(
                    icon: "calendar",
                    label: "Schedule Task",
                    color: AppColors.accentBlue
                ) {
                    print("Schedule tapped")
                },
                FABMenuItem(
                    icon: "folder.fill",
                    label: "Create Project",
                    color: AppColors.accentPurple
                ) {
                    print("Project tapped")
                },
                FABMenuItem(
                    icon: "plus.circle.fill",
                    label: "Quick Add",
                    color: AppColors.accentGreen
                ) {
                    print("Quick add tapped")
                }
            ]
        )
        .padding(AppSpacing.lg)
    }
}
