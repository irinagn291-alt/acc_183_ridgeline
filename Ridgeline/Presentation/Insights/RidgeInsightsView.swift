import SwiftUI

/// Written readouts derived from ascent history.
public struct RidgeInsightsView: View {
    @Bindable var viewModel: RidgeInsightsViewModel

    public init(viewModel: RidgeInsightsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                RidgeSectionLabel("CONTOUR NOTES")
                Text("Insights")
                    .font(TopoType.title(24))
                    .foregroundStyle(RidgePalette.cream)

                if viewModel.isLoading && viewModel.insights.isEmpty {
                    ProgressView().tint(RidgePalette.summit)
                } else {
                    ForEach(viewModel.insights) { insight in
                        insightRow(insight)
                    }
                }
            }
            .padding(RidgeMetrics.gutter)
        }
        .ridgeGround()
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private func insightRow(_ insight: RidgeInsight) -> some View {
        HStack(alignment: .top, spacing: RidgeMetrics.inset) {
            Rectangle()
                .fill(tint(for: insight.kind))
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(TopoType.bodyBold())
                    .foregroundStyle(RidgePalette.cream)
                Text(insight.detail)
                    .font(TopoType.body(14))
                    .foregroundStyle(RidgePalette.creamDim)
            }
            Spacer(minLength: 0)
        }
        .padding(RidgeMetrics.inset)
        .background(RidgePalette.contours.opacity(0.35))
        .overlay {
            Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
        }
    }

    private func tint(for kind: RidgeInsightKind) -> Color {
        switch kind {
        case .gain: return RidgePalette.summit
        case .pace: return RidgePalette.cream
        case .distance: return RidgePalette.contours
        case .encouragement: return RidgePalette.creamDim
        }
    }
}

#Preview {
    NavigationStack {
        RidgeInsightsView(viewModel: RidgelineContainer.preview().makeInsightsViewModel())
    }
}
