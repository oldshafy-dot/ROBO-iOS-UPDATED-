import SwiftUI

struct LicenseGateView: View {
    @EnvironmentObject private var session: LicenseSessionController
    @EnvironmentObject private var updates: ContentUpdateController
    @EnvironmentObject private var store: PatchProjectStore

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                AppLaunchLoadingView()
            case .unconfigured:
                if ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 17 {
                    LicenseActivationView()
                } else {
                    Color.clear.onAppear { RuntimeGuard.seal() }
                }
            case .signedOut:
                LicenseActivationView()
            case .authenticated:
                if session.hasLiveAuthority {
                    authenticatedRoot
                } else if updates.integrityCompromised {
                    Color.clear.onAppear { RuntimeGuard.rejectTamper() }
                } else {
                    AppLaunchLoadingView()
                }
            case .blocked(let message):
                LicenseBlockedView(message: message)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await session.startIfNeeded()
            await session.renewAuthorityIfNeeded()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 20_000_000_000)
                await session.renewAuthorityIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var authenticatedRoot: some View {
        if let release = updates.requiredRelease {
            RequiredContentUpdateView(release: release)
        } else if updates.integrityCompromised {
            Color.clear.onAppear { RuntimeGuard.rejectTamper() }
        } else if updates.hasVerifiedPolicy {
            ContentView()
        } else {
            ContentPolicyVerificationView()
        }
    }

}

private struct ContentPolicyVerificationView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var session: LicenseSessionController
    @EnvironmentObject private var updates: ContentUpdateController
    @EnvironmentObject private var store: PatchProjectStore

    var body: some View {
        ZStack {
            AppLaunchLoadingView()
            if let error = updates.errorMessage, !updates.isChecking {
                VStack(spacing: 14) {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                    Button(language.text("license.retry")) {
                        Task {
                            await updates.checkForUpdates(
                                session: session,
                                store: store
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(updates.isChecking)
                }
                .padding(28)
            }
        }
        .task {
            await updates.checkForUpdates(session: session, store: store)
        }
    }
}

private struct AppLaunchLoadingView: View {
    @Environment(\.appLanguage) private var language

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            FallingStarsBackground()
            VStack(spacing: 0) {
                Text("ROBO EXTERNAL")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                Spacer()
                VStack(spacing: 14) {
                    ProgressView()
                        .tint(AppTheme.accent)
                        .scaleEffect(1.15)
                    Text(language.text("license.loading"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white)
                }
                Spacer()
            }
            .padding(.horizontal, 36)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(language.text("license.loading_accessibility"))
    }
}

struct LicenseActivationView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var session: LicenseSessionController
    @State private var licenseKey = ""
    @State private var showSettings = false
    @AppStorage(AppTheme.accentStorageKey) private var accentHex = AppTheme.defaultAccentHex

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            FallingStarsBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                            .frame(width: 38, height: 38)
                            .background(AppTheme.accent.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(language.text("common.settings"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 36)
                        header
                        form
                            .padding(.top, 36)
                        if let error = session.errorMessage {
                            Label(language.licenseMessage(error), systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 18)
                                .accessibilityLabel(language.text("license.activation_error_accessibility", error))
                        }
                        Spacer(minLength: 36)
                    }
                    .padding(.horizontal, 28)
                    .frame(maxWidth: 420)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        }
        .tint(AppTheme.accent)
        .sheet(isPresented: $showSettings) {
            SettingsView(licenseScreen: true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(AppTheme.accent)
                }
                .accessibilityLabel(language.text("common.settings"))
            }
        }
    }

    private var header: some View {
        (Text("ROBO ") + Text("iOS").foregroundColor(AppTheme.accent))
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("ROBO iOS")
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(language.text("license.key_title"))
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AppTheme.tertiaryText)

            HStack(spacing: 10) {
                Image(systemName: "key.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .accessibilityHidden(true)

                SecureField(language.text("license.key_placeholder"), text: $licenseKey)
                    .textContentType(.password)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white)
                    .disabled(session.isWorking)
                    .accessibilityLabel(language.text("license.key_accessibility"))
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(Color.white.opacity(0.06), in: Capsule())

            Button {
                Task {
                    await session.beginActivation(licenseKey: licenseKey)
                    if session.state == .authenticated {
                        licenseKey = ""
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if session.isWorking {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "key.fill")
                    }
                    Text(session.isWorking ? language.text("license.activating") : language.text("license.activate"))
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    AppTheme.accentGradient,
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .disabled(session.isWorking || licenseKey.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty)
            .opacity(
                licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? 0.55
                    : 1
            )
            .padding(.top, 10)

            VStack(spacing: 10) {
                Link(destination: URL(string: "https://t.me/roboios")!) {
                    HStack(spacing: 10) {
                        Text("ROBO OFFICIAL")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.72), in: Capsule())
                    
                }
                .buttonStyle(.plain)
                .accessibilityLabel(language.text("license.robo_official_accessibility"))

                Link(destination: URL(string: "https://t.me/shafaycheatsff")!) {
                    HStack(spacing: 10) {
                        Text("Shafay Dev")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "message.fill")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.72), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(language.text("license.shafay_dev_accessibility"))
            }
            .padding(.top, 18)

        }
    }
}

struct LoginNoticeCard: View {
    @Environment(\.appLanguage) private var language
    let message: String
    let onOpen: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(language.text("common.close"))
                }
                Text(language.text("license.open_bot"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                Text(language.text("license.daily_updates"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.top, 6)
                Text(message)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 18)
                Button(action: onOpen) {
                    Text(language.text("license.open_bot"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            AppTheme.accentGradient,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 22)
                .accessibilityLabel(language.text("license.open_bot_accessibility"))
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 28)
        }
        .accessibilityElement(children: .contain)
    }
}

struct LicenseConfigurationView: View {
    @Environment(\.appLanguage) private var language
    let message: String

    var body: some View {
        LicenseMessagePage<EmptyView>(
            icon: "gear.badge.xmark",
            title: language.text("license.configuration_title"),
            message: message,
            detail: language.text("license.configuration_detail")
        )
    }
}

struct LicenseBlockedView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var session: LicenseSessionController
    let message: String

    var body: some View {
        LicenseMessagePage(
            icon: "wifi.exclamationmark",
            title: language.text("license.unavailable_title"),
            message: message,
            detail: language.text("license.unavailable_detail")
        ) {
            Button(language.text("license.retry")) {
                Task { await session.retrySession() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(session.isWorking)

            Button(language.text("license.log_out"), role: .destructive) {
                session.logout()
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct LicenseMessagePage<Actions: View>: View {
    let icon: String
    let title: String
    let message: String
    let detail: String
    let actions: Actions

    init(
        icon: String,
        title: String,
        message: String,
        detail: String,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.detail = detail
        self.actions = actions()
    }

    var body: some View {
        ZStack {
            AppTheme.pageBackground.ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
                actions
            }
            .multilineTextAlignment(.center)
            .padding(28)
            .frame(maxWidth: 480)
        }
    }
}

private extension LicenseMessagePage where Actions == EmptyView {
    init(icon: String, title: String, message: String, detail: String) {
        self.init(icon: icon, title: title, message: message, detail: detail) {
            EmptyView()
        }
    }
}

struct RequiredContentUpdateView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var session: LicenseSessionController
    @EnvironmentObject private var updates: ContentUpdateController
    @EnvironmentObject private var store: PatchProjectStore
    let release: ContentReleaseManifest

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            FallingStarsBackground()
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 36) {
                        Spacer(minLength: 48)
                        Text("ROBO EXTERNAL")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                        releaseNotes
                        if let error = updates.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel(language.text("license.update_error_accessibility", error))
                        }
                        installButton
                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 430)
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .interactiveDismissDisabled()
        .preferredColorScheme(.dark)
        .task {
            await updates.checkForUpdates(session: session, store: store)
        }
    }

    private var descriptionLines: [String] {
        let lines = (release.description ?? "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines.isEmpty ? [language.text("license.update_default_description")] : lines
    }

    private var releaseNotes: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                VitaProfileIcon(systemName: "doc.fill")
                Text(language.text("license.whats_new"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 8)
                Text("v\(release.version)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.leading, 60)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(descriptionLines.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                            .accessibilityHidden(true)
                        Text(line)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .background(
            Color.white.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private var installButton: some View {
        Button {
            Task {
                await updates.installRequired(session: session, store: store)
            }
        } label: {
            HStack(spacing: 10) {
                if updates.isInstalling {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
                Text(updates.isInstalling ? language.text("license.installing") : language.text("license.download_install"))
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(AppTheme.accent, in: Capsule())
            .shadow(color: AppTheme.accent.opacity(0.45), radius: 18, y: 0)
        }
        .buttonStyle(.plain)
        .disabled(updates.isInstalling)
        .accessibilityHint(language.text("license.update_accessibility_hint"))
    }
}
