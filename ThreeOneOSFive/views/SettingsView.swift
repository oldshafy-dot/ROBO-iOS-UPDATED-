import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @AppStorage(AppLanguage.storageKey) private var savedLanguageCode = AppLanguage.english.rawValue
    @AppStorage(AppTheme.accentStorageKey) private var savedAccentHex = AppTheme.defaultAccentHex
    @AppStorage(AppTheme.streamerModeStorageKey) private var savedStreamerMode = false
    @AppStorage(FeatureVisibility.developerModeStorageKey) private var developerModeEnabled = false

    @State private var draftLanguageCode = AppLanguage.english.rawValue
    @State private var draftAccentHex = AppTheme.defaultAccentHex
    @State private var draftStreamerMode = false
    @State private var customHex = AppTheme.defaultAccentHex
    @State private var showSaved = false
    @State private var invalidColor = false

    private let presets: [(name: String, hex: String)] = [
        ("Red", "#F53331"),
        ("Blue", "#147BFF"),
        ("Gold", "#FFD23F"),
        ("Orange", "#FF8A1F")
    ]

    private var language: AppLanguage {
        AppLanguage(rawValue: draftLanguageCode) ?? .english
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()
                FallingStarsBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        accentSection
                        languageSection
                        streamerSection
                        deviceSection
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let validLanguage = AppLanguage(rawValue: savedLanguageCode)
            if validLanguage == nil {
                savedLanguageCode = AppLanguage.english.rawValue
            }
            let validAccent = Color.normalizedHex(savedAccentHex).flatMap {
                Color.isAllowedAccentHex($0) ? $0 : nil
            } ?? AppTheme.defaultAccentHex

            if validAccent != savedAccentHex {
                savedAccentHex = validAccent
            }

            draftLanguageCode = (validLanguage ?? .english).rawValue
            draftAccentHex = validAccent
            customHex = validAccent
            draftStreamerMode = savedStreamerMode
        }
        .alert(language.text("settings.invalid_color"), isPresented: $invalidColor) {
            Button(language.text("common.done"), role: .cancel) {}
        } message: {
            Text(language.text("settings.invalid_color_message"))
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(language.text("common.back"))

            VStack(alignment: .leading, spacing: 3) {
                Text("Robo iOS")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.white)
                Text(language.text("settings.subtitle"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
    }

    private var accentSection: some View {
        settingsCard(title: language.text("settings.accent_color"), icon: "paintpalette.fill") {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: draftAccentHex))
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                Text(draftAccentHex.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(spacing: 10) {
                ForEach(presets, id: \.hex) { preset in
                    Button {
                        draftAccentHex = preset.hex
                        customHex = preset.hex
                    } label: {
                        VStack(spacing: 7) {
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 34, height: 34)
                                .overlay {
                                    if draftAccentHex.caseInsensitiveCompare(preset.hex) == .orderedSame {
                                        Circle().stroke(.white, lineWidth: 2)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            Text(language.text("settings.color_\(preset.name.lowercased())"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(language.text("settings.custom_color"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 10) {
                    TextField("#RRGGBB", text: $customHex)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Button(language.text("settings.apply")) {
                        applyCustomColor()
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color(hex: draftAccentHex), in: Capsule())
                }
            }

            Text(language.text("settings.no_black"))
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.tertiaryText)
        }
    }

    private var languageSection: some View {
        settingsCard(title: language.text("settings.language"), icon: "globe") {
            VStack(spacing: 0) {
                ForEach(AppLanguage.allCases) { option in
                    Button {
                        draftLanguageCode = option.rawValue
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            if draftLanguageCode == option.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(.plain)

                    if option.id != AppLanguage.allCases.last?.id {
                        Rectangle()
                            .fill(AppTheme.hairline)
                            .frame(height: 0.5)
                    }
                }
            }
        }
    }

    private var streamerSection: some View {
        settingsCard(title: language.text("settings.streamer_mode"), icon: "record.circle") {
            Toggle(isOn: $draftStreamerMode) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(language.text("settings.streamer_mode"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(language.text("settings.streamer_mode_footer"))
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .tint(AppTheme.accent)
        }
    }

    private var deviceSection: some View {
        settingsCard(title: language.text("common.device"), icon: "iphone") {
            settingRow(language.text("dashboard.hardware_model"), AppInfo.displayMachineName)
            settingRow(language.text("settings.ios_version"), "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
            settingRow(
                language.text("settings.current_version"),
                language.text(appState.isSupported ? "settings.supported" : "settings.unsupported")
            )
        }
    }

    private var saveButton: some View {
        Button {
            saveSettings()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: showSaved ? "checkmark.circle.fill" : "checkmark")
                Text(showSaved ? language.text("settings.saved") : language.text("settings.save"))
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: draftAccentHex), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.accent)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 0.5)
        }
    }

    private func settingRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }

    private func applyCustomColor() {
        guard let normalized = Color.normalizedHex(customHex),
              Color.isAllowedAccentHex(normalized) else {
            invalidColor = true
            return
        }
        draftAccentHex = normalized
    }

    private func saveSettings() {
        guard let normalized = Color.normalizedHex(draftAccentHex),
              Color.isAllowedAccentHex(normalized) else {
            invalidColor = true
            return
        }

        savedLanguageCode = AppLanguage(rawValue: draftLanguageCode)?.rawValue ?? AppLanguage.english.rawValue
        savedAccentHex = normalized
        savedStreamerMode = draftStreamerMode
        customHex = normalized
        showSaved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            dismiss()
        }
    }
}
