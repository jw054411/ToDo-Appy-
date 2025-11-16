import SwiftUI

/// AppAnimations - Consistent animation system for smooth, polished interactions
struct AppAnimations {
    // MARK: - Standard Animations

    /// Quick animation for subtle interactions (0.15s)
    static let quick = Animation.easeOut(duration: 0.15)

    /// Standard animation for most interactions (0.25s)
    static let standard = Animation.easeInOut(duration: 0.25)

    /// Smooth animation for page transitions (0.35s)
    static let smooth = Animation.easeInOut(duration: 0.35)

    /// Slow animation for emphasis (0.5s)
    static let slow = Animation.easeInOut(duration: 0.5)

    // MARK: - Spring Animations

    /// Bouncy spring for playful interactions
    static let springBouncy = Animation.spring(response: 0.3, dampingFraction: 0.6)

    /// Standard spring for buttons and taps
    static let springStandard = Animation.spring(response: 0.4, dampingFraction: 0.8)

    /// Smooth spring for sheet presentations
    static let springSmooth = Animation.spring(response: 0.35, dampingFraction: 0.85)

    /// Gentle spring for subtle movements
    static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.9)

    // MARK: - Specific Use Cases

    /// Checkbox tap animation (bouncy spring)
    static let checkboxTap = springBouncy

    /// Swipe action reveal animation (ease out)
    static let swipeReveal = Animation.easeOut(duration: 0.25)

    /// Item insert/add animation (smooth spring)
    static let itemInsert = springStandard

    /// Sheet slide animation (smooth spring)
    static let sheetSlide = springSmooth

    /// Item delete animation (quick ease in)
    static let itemDelete = Animation.easeIn(duration: 0.2)

    /// List reorder animation (standard ease)
    static let listReorder = standard

    /// Button press animation (quick spring)
    static let buttonPress = springBouncy

    /// Fade in/out animation
    static let fade = Animation.easeInOut(duration: 0.3)

    /// Scale animation for focus effects
    static let scale = springStandard

    /// Rotation animation for loading spinners
    static let rotate = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
}

/// AppHaptics - Haptic feedback manager for tactile responses
struct AppHaptics {
    // MARK: - Impact Feedback

    /// Light impact (checkbox, toggle)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (button press)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (delete, important action)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Soft impact (subtle interaction)
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    /// Rigid impact (precise interaction)
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success feedback (task completed)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback (important action)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback (failed action)
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed (swipe action, picker)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - View Extensions for Animations

extension View {
    /// Apply standard fade transition
    func fadeTransition() -> some View {
        self.transition(.opacity.animation(AppAnimations.fade))
    }

    /// Apply scale transition
    func scaleTransition() -> some View {
        self.transition(.scale.animation(AppAnimations.scale))
    }

    /// Apply slide transition from bottom
    func slideUpTransition() -> some View {
        self.transition(.move(edge: .bottom).combined(with: .opacity).animation(AppAnimations.sheetSlide))
    }

    /// Apply slide transition from trailing
    func slideTrailingTransition() -> some View {
        self.transition(.move(edge: .trailing).combined(with: .opacity).animation(AppAnimations.swipeReveal))
    }

    /// Animate on tap with scale effect
    func animatedTap(action: @escaping () -> Void) -> some View {
        self.modifier(AnimatedTapModifier(action: action))
    }
}

// MARK: - Animated Tap Modifier

private struct AnimatedTapModifier: ViewModifier {
    let action: () -> Void
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppAnimations.buttonPress, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            AppHaptics.light()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

// MARK: - Preview

#Preview("Animations") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            // Checkbox animation demo
            CheckboxAnimationDemo()

            // Button press demo
            ButtonPressDemo()

            // Swipe action demo
            SwipeActionDemo()

            // Loading spinner demo
            LoadingSpinnerDemo()
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}

// MARK: - Preview Components

private struct CheckboxAnimationDemo: View {
    @State private var isChecked = false

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Checkbox Animation")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Button(action: {
                withAnimation(AppAnimations.checkboxTap) {
                    isChecked.toggle()
                }
                AppHaptics.light()
            }) {
                HStack {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundColor(isChecked ? AppColors.accentGreen : AppColors.textSecondary)
                        .scaleEffect(isChecked ? 1.1 : 1.0)

                    Text("Tap to toggle")
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(AppSpacing.md)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(AppCornerRadius.md)
            }
        }
    }
}

private struct ButtonPressDemo: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Button Press Animation")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Text("Taps: \(count)")
                .font(AppTypography.bodyBold)
                .foregroundColor(AppColors.textSecondary)

            Button(action: {
                count += 1
                AppHaptics.medium()
            }) {
                Text("Press Me")
                    .font(AppTypography.bodyBold)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.accentBlue)
                    .cornerRadius(AppCornerRadius.md)
            }
            .animatedTap {
                count += 1
                AppHaptics.medium()
            }
        }
    }
}

private struct SwipeActionDemo: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Swipe Action Animation")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            ZStack(alignment: .trailing) {
                // Background action
                HStack {
                    Spacer()
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .padding(AppSpacing.md)
                }
                .background(AppColors.accentRed)

                // Main content
                HStack {
                    Image(systemName: "circle")
                        .foregroundColor(AppColors.textSecondary)
                    Text("Swipe left to delete")
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(AppColors.backgroundSecondary)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -80)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(AppAnimations.swipeReveal) {
                                offset = 0
                            }
                        }
                )
            }
            .cornerRadius(AppCornerRadius.md)
            .clipped()
        }
    }
}

private struct LoadingSpinnerDemo: View {
    @State private var isRotating = false

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Loading Spinner Animation")
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 32))
                .foregroundColor(AppColors.accentBlue)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(AppAnimations.rotate, value: isRotating)
                .onAppear {
                    isRotating = true
                }
        }
    }
}
