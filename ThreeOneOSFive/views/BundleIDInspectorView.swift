
import SwiftUI
import UniformTypeIdentifiers

struct BundleIDInspectorView: View {

    @State private var isImporting = false
    @State private var isLoading = false
    @State private var metadata: ApplicationBundleMetadata?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Image(systemName: "app.badge.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Bundle ID Inspector")
                    .font(.title2.bold())

                Text("Select an IPA or APP file to inspect its application metadata.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    isImporting = true
                } label: {
                    Label("Select IPA / APP", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if isLoading {
                    ProgressView("Reading application metadata...")
                }

                if let metadata {
                    VStack(alignment: .leading, spacing: 14) {

                        metadataRow("App Name", metadata.displayName)
                        metadataRow("Bundle ID", metadata.bundleID)
                        metadataRow("Version", metadata.version)
                        metadataRow("Build Number", metadata.buildNumber)

                        Button {
                            UIPasteboard.general.string = metadata.bundleID
                        } label: {
                            Label("Copy Bundle ID", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.secondary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Bundle ID Finder")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [
                    UTType(filenameExtension: "ipa") ?? .zip,
                    .applicationBundle
                ],
                allowsMultipleSelection: false
            ) { result in
                inspect(result)
            }
        }
    }

    private func metadataRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.isEmpty ? "Unavailable" : value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private func inspect(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            isLoading = true
            errorMessage = nil
            metadata = nil

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try ApplicationMetadataSelectionReader.read(
                        from: url
                    )

                    DispatchQueue.main.async {
                        metadata = result
                        isLoading = false
                    }

                } catch {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                }
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
