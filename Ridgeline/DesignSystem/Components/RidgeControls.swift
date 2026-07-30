import SwiftUI

public struct RidgeButton: View {
    private let title: String
    private let accent: Bool
    private let action: () -> Void

    public init(_ title: String, accent: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.accent = accent
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(TopoType.bodyBold())
                .foregroundStyle(accent ? RidgePalette.ground : RidgePalette.cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(accent ? RidgePalette.summit : RidgePalette.contours)
                .overlay {
                    Rectangle()
                        .strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
                }
        }
        .buttonStyle(.plain)
    }
}

public struct RidgeEmptyState: View {
    private let title: String
    private let detail: String

    public init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(spacing: RidgeMetrics.inset) {
            Image("EmptyTrail")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 140)
                .accessibilityHidden(true)
            Text(title)
                .font(TopoType.title(24))
                .foregroundStyle(RidgePalette.cream)
                .multilineTextAlignment(.center)
            Text(detail)
                .font(TopoType.body())
                .foregroundStyle(RidgePalette.creamDim)
                .multilineTextAlignment(.center)
        }
        .padding(RidgeMetrics.gutter)
        .frame(maxWidth: .infinity)
    }
}

public struct RidgeLoadingState: View {
    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: RidgeMetrics.inset) {
            ProgressView()
                .tint(RidgePalette.summit)
            Text(message)
                .font(TopoType.body())
                .foregroundStyle(RidgePalette.creamDim)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct RidgeSectionLabel: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(TopoType.badge())
            .foregroundStyle(RidgePalette.creamDim)
            .tracking(1.4)
    }
}
