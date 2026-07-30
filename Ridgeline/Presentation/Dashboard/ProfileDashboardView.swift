import SwiftUI

/// Hero dashboard: ridge cross-section, totals, and navigation chips.
public struct ProfileDashboardView: View {
    @Bindable var viewModel: ProfileDashboardViewModel
    @Bindable var coordinator: RidgelineCoordinator

    public init(viewModel: ProfileDashboardViewModel, coordinator: RidgelineCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                    hero
                    profileBlock
                    totalsRow
                    navChips
                }
                .padding(RidgeMetrics.gutter)
                .padding(.bottom, 88)
            }

            fab
        }
        .ridgeGround()
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image("BrandMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("Ridgeline")
                        .font(TopoType.title(18))
                        .foregroundStyle(RidgePalette.cream)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.openSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(RidgePalette.creamDim)
                }
                .accessibilityLabel("Settings")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private var hero: some View {
        Image("DashboardHero")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: RidgeMetrics.heroHeight)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    RidgeSectionLabel("ELEVATION JOURNAL")
                    Text("Cross-section of your climbs")
                        .font(TopoType.body())
                        .foregroundStyle(RidgePalette.cream)
                }
                .padding(RidgeMetrics.inset)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RidgePalette.ground.opacity(0.72))
            }
            .overlay {
                Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
            }
            .accessibilityLabel("Dashboard hero ridge landscape")
    }

    @ViewBuilder
    private var profileBlock: some View {
        if viewModel.ascents.isEmpty && !viewModel.isLoading {
            RidgeEmptyState(
                title: "No contours yet",
                detail: "Tap the summit button to log your first ascent."
            )
        } else {
            VStack(alignment: .leading, spacing: RidgeMetrics.inset) {
                RidgeSectionLabel("RIDGE PROFILE")
                RidgeProfileView(
                    samples: viewModel.profileSamples.isEmpty
                        ? BuildElevationProfileUseCase.demoProfile()
                        : viewModel.profileSamples,
                    parallaxEnabled: viewModel.preferences.parallaxEnabled
                )
            }
        }
    }

    private var totalsRow: some View {
        HStack(spacing: RidgeMetrics.inset) {
            metric(
                label: "GAIN",
                value: String(format: "%.0f m", viewModel.totals.totalGainMeters)
            )
            metric(
                label: "DISTANCE",
                value: String(format: "%.1f km", viewModel.totals.totalDistanceKilometers)
            )
            metric(
                label: "ASCENTS",
                value: "\(viewModel.totals.ascentCount)"
            )
        }
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RidgeSectionLabel(label)
            Text(value)
                .font(TopoType.monoBold(16))
                .foregroundStyle(RidgePalette.cream)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(RidgeMetrics.inset)
        .background(RidgePalette.contours.opacity(0.35))
        .overlay {
            Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
        }
    }

    private var navChips: some View {
        VStack(spacing: RidgeMetrics.inset) {
            navChip(title: "Charts", detail: "Gain, pace, distance, records", systemImage: "chart.xyaxis.line") {
                coordinator.openCharts()
            }
            navChip(title: "Insights", detail: "Written read on your climbs", systemImage: "text.alignleft") {
                coordinator.openInsights()
            }
            navChip(title: "History", detail: "Every logged ascent", systemImage: "list.bullet") {
                coordinator.openHistory()
            }
        }
    }

    private func navChip(
        title: String,
        detail: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: RidgeMetrics.inset) {
                Image(systemName: systemImage)
                    .foregroundStyle(RidgePalette.summit)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TopoType.bodyBold())
                        .foregroundStyle(RidgePalette.cream)
                    Text(detail)
                        .font(TopoType.body(13))
                        .foregroundStyle(RidgePalette.creamDim)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(RidgePalette.creamFaint)
            }
            .padding(RidgeMetrics.inset)
            .background(RidgePalette.contours.opacity(0.3))
            .overlay {
                Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
            }
        }
        .buttonStyle(.plain)
    }

    private var fab: some View {
        Button {
            coordinator.presentLogAscent()
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(RidgePalette.ground)
                .frame(width: RidgeMetrics.fabSize, height: RidgeMetrics.fabSize)
                .background(RidgePalette.summit)
                .overlay {
                    Circle().strokeBorder(RidgePalette.cream.opacity(0.35), lineWidth: 1)
                }
        }
        .padding(.trailing, RidgeMetrics.gutter)
        .padding(.bottom, RidgeMetrics.gutter)
        .accessibilityLabel("Log ascent")
    }
}

#Preview {
    NavigationStack {
        ProfileDashboardView(
            viewModel: RidgelineContainer.preview().makeDashboardViewModel(),
            coordinator: RidgelineCoordinator()
        )
    }
}
