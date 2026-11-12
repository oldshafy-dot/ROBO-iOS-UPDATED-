import Foundation

enum ExploitSupportPolicy {
    static let verifiedIOS16Range = "16.0–16.7.x"
    static let verifiedIOS17Range = "17.0–17.7.x"
    static let verifiedIOS18Range = "18.0–18.7.1"
    static let verifiedIOS26Range = "26.0–26.6.1"

    enum FeatureLevel: Equatable {
        case unsupported
        case uiOnly
        case verifiedKernelAccess
    }

    static func supportsKernelExploit(major: Int, minor: Int, patch: Int) -> Bool {
        guard minor >= 0, patch >= 0 else { return false }

        if major == 17 {
            return minor <= 7
        }

        if major == 18 {
            return minor < 7 || (minor == 7 && patch <= 1)
        }

        return false
    }

    static func isUILaunchSupported(major: Int) -> Bool {
        major >= 16
    }

    static func isOSRecognized(
        major: Int,
        minor: Int,
        patch: Int,
        build: String
    ) -> Bool {
        guard minor >= 0, patch >= 0 else { return false }

        switch major {
        case 16:
            return minor <= 7
        case 17:
            return minor <= 7
        case 18:
            return minor < 7 || (minor == 7 && patch <= 1)
        case 26:
            return minor < 6 || (minor == 6 && patch <= 1)
        case 27:
            // iOS 27 is recognized by version/build detection, but this
            // project does not claim verified target-container access for it.
            return !build.isEmpty && build != "Unknown"
        default:
            return false
        }
    }

    static func featureLevel(
        major: Int,
        minor: Int,
        patch: Int,
        build: String
    ) -> FeatureLevel {
        guard isUILaunchSupported(major: major) else {
            return .unsupported
        }

        if supportsKernelExploit(major: major, minor: minor, patch: patch) {
            return .verifiedKernelAccess
        }

        return .uiOnly
    }

    // This is intentionally the UI/launch policy. It must not be used as
    // proof that target-container access or any individual feature works.
    static func isSupported(
        major: Int,
        minor: Int,
        patch: Int,
        build: String
    ) -> Bool {
        isUILaunchSupported(major: major)
    }
}
