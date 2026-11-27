import Combine
import Foundation
import UIKit

enum LicenseGateState: Equatable {
    case loading
    case unconfigured(String)
    case signedOut
    case authenticated
    case blocked(String)
}

private struct ShafayVerifyResponse: Decodable {
    let success: Bool
    let status: String?
    let expiresAt: String?
    let deviceID: String?
    let devicesLinked: Int?
    let maxDevices: Int?
    let error: String?
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case success, status
        case expiresAt = "expires_at"
        case deviceID = "device_id"
        case devicesLinked = "devices_linked"
        case maxDevices = "max_devices"
        case error, message
    }
}

private struct StoredShafayLicense: Codable {
    let key: String
    let expiresAt: String
    let deviceID: String
}

@MainActor
final class LicenseSessionController: ObservableObject {
    @Published private(set) var state: LicenseGateState = .loading
    @Published private(set) var profile: LicenseProfile?
    @Published private(set) var displayLicenseKey: String?
    @Published private(set) var isWorking = false
    @Published private(set) var workspaceUnlocked = false
    @Published private(set) var authorityRevision = 0
    @Published var errorMessage: String?

    private let verifyURL = URL(string: "https://shafaykeyauthadmin.lovable.app/api/public/v1/verify-license")!
    private let optionsBaseURL = URL(string: "https://shafaykeyauthadmin.lovable.app/api/public/v1/patch/options")!
    private let storageKey = "robo.shafay.keyauth.v1"
    private var stored: StoredShafayLicense?
    private var started = false

    var hasLiveAuthority: Bool {
        guard case .authenticated = state,
              let stored,
              let expiry = Self.parseDate(stored.expiresAt) else {
            return false
        }
        return expiry > Date()
    }

    var serverBaseURL: URL? {
        URL(string: "https://shafaykeyauthadmin.lovable.app")
    }

    var manifestPublicKey: Data? { nil }

    func startIfNeeded() async {
        guard !started else { return }
        started = true
        state = .loading

        guard let saved = loadStoredLicense() else {
            state = .signedOut
            return
        }

        stored = saved
        displayLicenseKey = saved.key
        profile = Self.makeProfile(saved)
        await verifySavedLicense(saved)
    }

    func beginActivation(licenseKey: String) async {
        guard !isWorking else { return }

        let key = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            errorMessage = "Invalid License"
            return
        }

        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            var request = URLRequest(url: verifyURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 20
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "key": key,
                "device_id": deviceID,
                "product_identifier": "freefire"
            ])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw LicenseClientError.invalidResponse
            }

            let payload = try JSONDecoder().decode(ShafayVerifyResponse.self, from: data)

            if payload.success == true, payload.status?.lowercased() == "active",
               let expiresAt = payload.expiresAt, !expiresAt.isEmpty {
                let saved = StoredShafayLicense(
                    key: key,
                    expiresAt: expiresAt,
                    deviceID: payload.deviceID ?? deviceID
                )
                saveStoredLicense(saved)
                stored = saved
                displayLicenseKey = key
                profile = Self.makeProfile(saved)
                state = .authenticated
                workspaceUnlocked = true
                authorityRevision += 1
                errorMessage = nil
                return
            }

            if payload.error == "device_limit_reached" || http.statusCode == 403 {
                throw LicenseClientError.server("Key is already bound to another device.")
            }

            throw LicenseClientError.server(
                payload.message ?? payload.error ?? "Invalid License"
            )
        } catch {
            state = .signedOut
            workspaceUnlocked = false
            errorMessage = Self.friendlyLicenseMessage(error.localizedDescription)
        }
    }

    func sceneBecameActive() async {
        guard let stored else { return }
        await verifySavedLicense(stored)
    }

    func renewAuthorityIfNeeded() async {
        guard let stored else { return }
        guard let expiry = Self.parseDate(stored.expiresAt), expiry > Date() else {
            logout()
            errorMessage = "License expired."
            return
        }
        if state != .authenticated {
            await verifySavedLicense(stored)
        }
    }

    func requireOperationLease() async throws {
        guard hasLiveAuthority else {
            throw LicenseClientError.unauthorized
        }
    }

    func authorizedAccessToken() async throws -> String {
        guard hasLiveAuthority else {
            throw LicenseClientError.unauthorized
        }
        return stored?.key ?? ""
    }

    func loginNotice() async -> (message: String, url: URL)? {
        nil
    }

    func retrySession() async {
        guard let stored else {
            started = false
            await startIfNeeded()
            return
        }
        await verifySavedLicense(stored)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        stored = nil
        profile = nil
        displayLicenseKey = nil
        workspaceUnlocked = false
        authorityRevision += 1
        errorMessage = nil
        state = .signedOut
    }

    func fetchLatestManifest() async throws -> SignedManifestEnvelope? {
        nil
    }

    func downloadContentPackage(at url: URL) async throws -> Data {
        guard hasLiveAuthority else {
            throw LicenseClientError.unauthorized
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw LicenseClientError.server("Patch download failed.")
        }
        guard data.count <= 32 * 1024 * 1024 else {
            throw LicenseClientError.packageInvalid(url.lastPathComponent)
        }
        return data
    }

    func downloadRemotePatch(at url: URL) async throws -> Data {
        try await downloadContentPackage(at: url)
    }

    func authorizeWrite(
        packageID: UUID,
        packageData: Data,
        apply: Bool
    ) async throws {
        _ = packageID
        _ = packageData
        _ = apply
        guard hasLiveAuthority else {
            throw LicenseClientError.unauthorized
        }
    }

    private func verifySavedLicense(_ saved: StoredShafayLicense) async {
        guard let expiry = Self.parseDate(saved.expiresAt), expiry > Date() else {
            logout()
            errorMessage = "License expired."
            return
        }

        do {
            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            guard deviceID == saved.deviceID || saved.deviceID.isEmpty else {
                state = .signedOut
                workspaceUnlocked = false
                errorMessage = "Key is already bound to another device."
                return
            }

            var request = URLRequest(url: verifyURL)
            request.httpMethod = "POST"
            request.timeoutInterval = 20
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "key": saved.key,
                "device_id": deviceID,
                "product_identifier": "freefire"
            ])

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw LicenseClientError.invalidResponse
            }

            let payload = try JSONDecoder().decode(ShafayVerifyResponse.self, from: data)
            guard payload.success == true,
                  payload.status?.lowercased() == "active",
                  let expiresAt = payload.expiresAt,
                  let refreshed = Self.parseDate(expiresAt),
                  refreshed > Date() else {
                if payload.error == "device_limit_reached" || http.statusCode == 403 {
                    throw LicenseClientError.server("Key is already bound to another device.")
                }
                throw LicenseClientError.unauthorized
            }

            let refreshedStored = StoredShafayLicense(
                key: saved.key,
                expiresAt: expiresAt,
                deviceID: payload.deviceID ?? saved.deviceID
            )
            saveStoredLicense(refreshedStored)
            stored = refreshedStored
            profile = Self.makeProfile(refreshedStored)
            displayLicenseKey = refreshedStored.key
            state = .authenticated
            workspaceUnlocked = true
            authorityRevision += 1
            errorMessage = nil
        } catch {
            workspaceUnlocked = false
            if case LicenseClientError.unauthorized = error {
                state = .signedOut
                errorMessage = "License is not active."
            } else {
                state = .blocked(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func loadStoredLicense() -> StoredShafayLicense? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(StoredShafayLicense.self, from: data)
    }

    private func saveStoredLicense(_ value: StoredShafayLicense) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private static func makeProfile(_ value: StoredShafayLicense) -> LicenseProfile {
        LicenseProfile(
            licenseID: "shafay-\\(CatalogTrust.sha256Hex(Data(value.key.utf8)).prefix(16))",
            maskedKey: mask(value.key),
            expiresAt: value.expiresAt,
            registeredDevice: value.deviceID,
            udid: value.deviceID
        )
    }

    private static func mask(_ key: String) -> String {
        guard key.count > 8 else { return key }
        return String(key.prefix(4)) + String(repeating: "•", count: max(2, key.count - 8)) + String(key.suffix(4))
    }

    private static func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }

    private static func friendlyLicenseMessage(_ raw: String) -> String {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "Invalid License" }
        return text
    }
}
