import SafariServices
import SwiftUI

/// Hosted contact form opened from Settings.
public struct ContactUsWebView: View {
    @Environment(\.dismiss) private var dismiss

    private let contactURL = URL(string: "https://ridgeline-ascent.pro/contact-us")!

    public var body: some View {
        SafariView(url: contactURL)
            .ignoresSafeArea()
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
    }
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
