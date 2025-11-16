import SwiftUI

/// AppTextField - Styled text input component with consistent styling
struct AppTextField: View {
    // MARK: - Properties

    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isMultiline: Bool
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization

    // MARK: - State

    @FocusState private var isFocused: Bool

    // MARK: - Initializers

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isMultiline: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isMultiline = isMultiline
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: AppSpacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isFocused ? AppColors.accentBlue : AppColors.textSecondary)
                    .padding(.top, isMultiline ? AppSpacing.md : 0)
            }

            if isMultiline {
                TextField(
                    placeholder,
                    text: $text,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(autocapitalization)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    AppHaptics.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundTertiary)
        .cornerRadius(AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(
                    isFocused ? AppColors.accentBlue : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(AppAnimations.quick, value: isFocused)
    }
}

// MARK: - Secure TextField Variant

struct AppSecureField: View {
    // MARK: - Properties

    let placeholder: String
    @Binding var text: String
    let icon: String?

    // MARK: - State

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    // MARK: - Initializer

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = "lock.fill"
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isFocused ? AppColors.accentBlue : AppColors.textSecondary)
            }

            Group {
                if isRevealed {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(AppTypography.body)
            .foregroundColor(AppColors.textPrimary)
            .textInputAutocapitalization(.never)
            .focused($isFocused)

            Button(action: {
                isRevealed.toggle()
                AppHaptics.light()
            }) {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundTertiary)
        .cornerRadius(AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(
                    isFocused ? AppColors.accentBlue : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(AppAnimations.quick, value: isFocused)
    }
}

// MARK: - Search Field Variant

struct AppSearchField: View {
    // MARK: - Properties

    @Binding var text: String

    // MARK: - State

    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(isFocused ? AppColors.accentBlue : AppColors.textSecondary)

            TextField("Search", text: $text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .textInputAutocapitalization(.never)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    AppHaptics.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundTertiary)
        .cornerRadius(AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(
                    isFocused ? AppColors.accentBlue : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(AppAnimations.quick, value: isFocused)
    }
}

// MARK: - Preview

#Preview("AppTextField") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Text Input Fields")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Standard Text Field")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppTextField(
                        "Enter task title",
                        text: .constant(""),
                        icon: "pencil"
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("With Text")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppTextField(
                        "Enter task title",
                        text: .constant("Buy groceries"),
                        icon: "pencil"
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Multiline Text Field")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppTextField(
                        "Enter description",
                        text: .constant("This is a longer description that spans multiple lines"),
                        icon: "text.alignleft",
                        isMultiline: true
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Email Field")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppTextField(
                        "Email address",
                        text: .constant(""),
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Secure Field")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppSecureField(
                        "Password",
                        text: .constant("")
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Search Field")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    AppSearchField(text: .constant(""))
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
