import Combine
import CryptoKit
import Foundation

struct ContentFunctionMetadata: Codable, Equatable {
    let name: String
    let description: String
    let icon: String?
    let game: String?
    let sort: Int?

    init(
        name: String,
        description: String,
        icon: String? = nil,
        game: String? = nil,
        sort: Int? = nil
    ) {
        self.name = name
        self.description = description
        self.icon = icon
        self.game = game
        self.sort = sort
    }

    var gameSlug: String {
        let raw = (game ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
        if raw == "free-fire-max" || raw == "max" || raw == "freefiremax" {
            return "free-fire-max"
        }
        return "free-fire"
    }
}

enum ContentFunctionMetadataStore {
    private static let storageKey = "vita.content.function-metadata.v1"

    static func metadata(for packageID: UUID) -> ContentFunctionMetadata? {
        records()[packageID.uuidString]
    }

    static func save(_ metadata: ContentFunctionMetadata, for packageID: UUID) {
        var values = records()
        values[packageID.uuidString] = metadata
        guard let data = try? JSONEncoder().encode(values) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func isManaged(_ packageID: UUID) -> Bool {
        records()[packageID.uuidString] != nil
    }

    static func remove(_ packageID: UUID) {
        var values = records()
        values.removeValue(forKey: packageID.uuidString)
        if values.isEmpty {
            UserDefaults.standard.removeObject(forKey: storageKey)
        } else if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private static func records() -> [String: ContentFunctionMetadata] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let values = try? JSONDecoder().decode([String: ContentFunctionMetadata].self, from: data) else {
            return [:]
        }
        return values
    }
}

private struct ShafayPatchOptionsResponse: Decodable {
    let success: Bool
    let downloadURLExpiresIn: Int?
    let categories: [ShafayPatchCategory]

    private enum CodingKeys: String, CodingKey {
        case success
        case downloadURLExpiresIn = "download_url_expires_in"
        case categories
    }
}

private struct ShafayPatchCategory: Decodable {
    let category: String
    let name: String
    let options: [ShafayPatchOption]
}

struct ShafayPatchOption: Decodable, Identifiable {
    let id: String
    let category: String
    let name: String
    let available: Bool
    let hasFile: Bool
    let downloadURL: String
    let description: String?
    let icon: String?
    let passwordRequired: Bool?
    let locked: Bool?
    let sort: Int?

    private enum CodingKeys: String, CodingKey {
        case id, category, name, available
        case hasFile = "has_file"
        case downloadURL = "download_url"
        case description, icon
        case passwordRequired = "password_required"
        case locked, sort
    }
}

@MainActor
final class ContentUpdateController: ObservableObject {
    @Published var requiredRelease: ContentReleaseManifest? = nil
    @Published private(set) var isChecking = false
    @Published private(set) var isInstalling = false
    @Published var errorMessage: String?
    @Published private(set) var lastInstalledVersion: String?
    @Published private(set) var games: [ContentGameDescriptor] = [
        ContentGameDescriptor(name: "Free Fire Normal", bundleID: "com.dts.freefireth", icon: ""),
        ContentGameDescriptor(name: "Free Fire MAX", bundleID: "com.dts.freefiremax", icon: "")
    ]
    @Published private(set) var hasVerifiedPolicy = false
    @Published private(set) var integrityCompromised = false
    @Published private(set) var optionsByGame: [String: [ShafayPatchOption]] = [:]

    private var lastCheckAt: Date?

    func checkForUpdates(
        session: LicenseSessionController,
        store: PatchProjectStore
    ) async {
        guard !isChecking, !isInstalling else { return }
        guard session.hasLiveAuthority else {
            hasVerifiedPolicy = false
            return
        }
        if let lastCheckAt, Date().timeIntervalSince(lastCheckAt) < 5 { return }
        lastCheckAt = Date()

        isChecking = true
        errorMessage = nil
        defer { isChecking = false }

        do {
            let normal = try await fetchOptions(category: "free_fire_india", session: session)
            let max = try await fetchOptions(category: "pubg_mobile", session: session)

            optionsByGame = [
                "free-fire": normal.filter { $0.available && $0.hasFile },
                "free-fire-max": max.filter { $0.available && $0.hasFile }
            ]

            hasVerifiedPolicy = true
            requiredRelease = nil
            store.reload()
        } catch {
            errorMessage = error.localizedDescription
            hasVerifiedPolicy = false
        }
    }

    func installRequired(
        session: LicenseSessionController,
        store: PatchProjectStore
    ) async {
        await checkForUpdates(session: session, store: store)
    }

    private func fetchOptions(
        category: String,
        session: LicenseSessionController
    ) async throws -> [ShafayPatchOption] {
        guard var components = URLComponents(
            url: URL(string: "https://shafaykeyauthadmin.lovable.app/api/public/v1/patch/options")!,
            resolvingAgainstBaseURL: false
        ) else {
            throw LicenseClientError.invalidResponse
        }

        components.queryItems = [URLQueryItem(name: "category", value: category)]
        guard let url = components.url else {
            throw LicenseClientError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw LicenseClientError.server("Could not load patches.")
        }

        let payload = try JSONDecoder().decode(ShafayPatchOptionsResponse.self, from: data)
        guard payload.success else {
            throw LicenseClientError.server("Patch server returned an invalid response.")
        }

        return payload.categories.first(where: { $0.category == category })?.options ?? []
    }

    func downloadAndInstall(
        option: ShafayPatchOption,
        gameSlug: String,
        session: LicenseSessionController,
        password: String? = nil,
        store: PatchProjectStore
    ) async throws -> UUID {
        guard option.available, option.hasFile else {
            throw LicenseClientError.packageInvalid(option.name)
        }
        guard let url = URL(string: option.downloadURL),
              url.scheme?.lowercased() == "https" else {
            throw LicenseClientError.packageInvalid(option.name)
        }

        isInstalling = true
        defer { isInstalling = false }

        let data = try await session.downloadRemotePatch(at: url)

        let decoded: DecodedPatchPackage
        do {
            decoded = try PatchPackageCodec.decode(data, password: password)
        } catch {
            throw LicenseClientError.packageInvalid(
                option.passwordRequired == true
                    ? "(option.name) (password or file is invalid)"
                    : option.name
            )
        }

        try PatchProjectLibrary.installVerifiedContentPackage(data)

        ContentFunctionMetadataStore.save(
            ContentFunctionMetadata(
                name: option.name,
                description: option.description ?? "",
                icon: option.icon,
                game: gameSlug,
                sort: option.sort,
                serverID: option.id,
                passwordRequired: option.passwordRequired ?? false,
                locked: option.locked ?? false
            ),
            for: decoded.project.id
        )

        store.reload()
        return decoded.project.id
    }

    func options(for gameSlug: String) -> [ShafayPatchOption] {
        optionsByGame[gameSlug] ?? []
    }
}
