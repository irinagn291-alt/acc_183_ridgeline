import SwiftUI

/// Chronological list of logged ascents.
public struct AscentHistoryView: View {
    @Bindable var viewModel: AscentHistoryViewModel
    @Bindable var coordinator: RidgelineCoordinator

    public init(viewModel: AscentHistoryViewModel, coordinator: RidgelineCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            if viewModel.ascents.isEmpty && !viewModel.isLoading {
                RidgeEmptyState(
                    title: "Trail empty",
                    detail: "Logged climbs will appear here."
                )
            } else {
                List {
                    ForEach(viewModel.ascents) { ascent in
                        Button {
                            coordinator.openEditAscent(ascent.id)
                        } label: {
                            ascentRow(ascent)
                        }
                        .listRowBackground(RidgePalette.contours.opacity(0.35))
                        .listRowSeparatorTint(RidgePalette.creamFaint)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.delete(viewModel.ascents[index])
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .ridgeGround()
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private func ascentRow(_ ascent: AscentLog) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ascent.title)
                .font(TopoType.bodyBold())
                .foregroundStyle(RidgePalette.cream)
            HStack(spacing: RidgeMetrics.inset) {
                Text(String(format: "%.1f km", ascent.distanceKilometers))
                Text("·")
                Text(String(format: "%.0f m", ascent.elevationGainMeters))
                if let pace = ascent.paceMinutesPerKilometer {
                    Text("·")
                    Text(String(format: "%.1f min/km", pace))
                }
            }
            .font(TopoType.mono(12))
            .foregroundStyle(RidgePalette.creamDim)
            Text(ascent.climbedAt.formatted(date: .abbreviated, time: .omitted))
                .font(TopoType.body(12))
                .foregroundStyle(RidgePalette.creamFaint)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AscentHistoryView(
            viewModel: RidgelineContainer.preview().makeHistoryViewModel(),
            coordinator: RidgelineCoordinator()
        )
    }
}
