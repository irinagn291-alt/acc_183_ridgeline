import Charts
import SwiftUI

/// Stats: total gain, pace vs grade, distance distribution, personal records.
public struct RidgeChartsView: View {
    @Bindable var viewModel: RidgeChartsViewModel

    public init(viewModel: RidgeChartsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                RidgeSectionLabel("READOUT")
                Text("Elevation statistics")
                    .font(TopoType.title(24))
                    .foregroundStyle(RidgePalette.cream)

                if viewModel.isLoading && viewModel.totals.ascentCount == 0 {
                    ProgressView().tint(RidgePalette.summit)
                } else if viewModel.totals.ascentCount == 0 {
                    RidgeEmptyState(
                        title: "No data yet",
                        detail: "Log ascents to fill the charts."
                    )
                } else {
                    totalsPanel
                    pacePanel
                    distancePanel
                    recordsPanel
                }
            }
            .padding(RidgeMetrics.gutter)
        }
        .ridgeGround()
        .navigationTitle("Charts")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
    }

    private var totalsPanel: some View {
        panel("TOTAL GAIN") {
            Text(String(format: "%.0f m", viewModel.totals.totalGainMeters))
                .font(TopoType.monoBold(28))
                .foregroundStyle(RidgePalette.summit)
                .contentTransition(.numericText())
            Text(String(
                format: "%.1f km across %d ascent%@",
                viewModel.totals.totalDistanceKilometers,
                viewModel.totals.ascentCount,
                viewModel.totals.ascentCount == 1 ? "" : "s"
            ))
            .font(TopoType.body(13))
            .foregroundStyle(RidgePalette.creamDim)
        }
    }

    private var pacePanel: some View {
        panel("PACE VS GRADE") {
            if viewModel.paceGrade.isEmpty {
                Text("Need distance and duration on climbs.")
                    .font(TopoType.body(13))
                    .foregroundStyle(RidgePalette.creamDim)
            } else {
                Chart(viewModel.paceGrade) { point in
                    PointMark(
                        x: .value("Grade %", point.gradePercent),
                        y: .value("Pace min/km", point.paceMinutesPerKilometer)
                    )
                    .foregroundStyle(RidgePalette.summit)
                }
                .chartXAxisLabel("Grade %")
                .chartYAxisLabel("min/km")
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(RidgePalette.contourDim)
                        AxisValueLabel().foregroundStyle(RidgePalette.creamDim)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(RidgePalette.contourDim)
                        AxisValueLabel().foregroundStyle(RidgePalette.creamDim)
                    }
                }
                .frame(height: 180)
            }
        }
    }

    private var distancePanel: some View {
        panel("DISTANCE DISTRIBUTION") {
            Chart(viewModel.distanceBuckets) { bucket in
                BarMark(
                    x: .value("Bucket", bucket.label),
                    y: .value("Count", bucket.count)
                )
                .foregroundStyle(RidgePalette.contours)
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(RidgePalette.contourDim)
                    AxisValueLabel().foregroundStyle(RidgePalette.creamDim)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(RidgePalette.creamDim)
                }
            }
            .frame(height: 160)
        }
    }

    private var recordsPanel: some View {
        panel("PERSONAL RECORDS") {
            recordRow("Highest gain", value: viewModel.records.highestGainMeters.map { String(format: "%.0f m", $0) })
            recordRow("Longest day", value: viewModel.records.longestDistanceKilometers.map { String(format: "%.1f km", $0) })
            recordRow("Fastest pace", value: viewModel.records.fastestPaceMinutesPerKilometer.map { String(format: "%.1f min/km", $0) })
            if let title = viewModel.records.mostRecentTitle {
                recordRow("Most recent", value: title)
            }
        }
    }

    private func recordRow(_ label: String, value: String?) -> some View {
        HStack {
            Text(label)
                .font(TopoType.body(14))
                .foregroundStyle(RidgePalette.creamDim)
            Spacer()
            Text(value ?? "—")
                .font(TopoType.mono(14))
                .foregroundStyle(RidgePalette.cream)
        }
    }

    private func panel<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: RidgeMetrics.inset) {
            RidgeSectionLabel(title)
            content()
        }
        .padding(RidgeMetrics.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RidgePalette.contours.opacity(0.35))
        .overlay {
            Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
        }
    }
}

#Preview {
    NavigationStack {
        RidgeChartsView(viewModel: RidgelineContainer.preview().makeChartsViewModel())
    }
}
