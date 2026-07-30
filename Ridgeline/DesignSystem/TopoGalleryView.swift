import SwiftUI

/// Design system gallery — every token and component state.
public struct TopoGalleryView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                section("Colour") {
                    ForEach(RidgePalette.inventory, id: \.name) { token in
                        HStack(spacing: RidgeMetrics.inset) {
                            Rectangle()
                                .fill(token.color)
                                .frame(width: 44, height: 28)
                                .overlay {
                                    Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: 1)
                                }
                            Text(token.name)
                                .font(TopoType.mono(13))
                                .foregroundStyle(RidgePalette.cream)
                            Spacer()
                        }
                    }
                }

                section("Type") {
                    Text("Copperplate — title").font(TopoType.title()).foregroundStyle(RidgePalette.cream)
                    Text("SF Pro — body").font(TopoType.body()).foregroundStyle(RidgePalette.creamDim)
                    Text("SF Mono 14.2").font(TopoType.mono()).foregroundStyle(RidgePalette.summit)
                }

                section("Profile") {
                    RidgeProfileView(
                        samples: BuildElevationProfileUseCase.demoProfile(),
                        parallaxEnabled: true
                    )
                }

                section("Components") {
                    RidgeButton("Log ascent") {}
                    RidgeEmptyState(
                        title: "No contours yet",
                        detail: "Log a climb to draw the ridge."
                    )
                }

                section("Motion") {
                    Text("Parallax budget: \(Int(RidgeMotion.parallaxBudget)) pt")
                        .font(TopoType.mono(13))
                        .foregroundStyle(RidgePalette.creamDim)
                    Text("Contour draw: linear \(RidgeMotion.contourDrawDuration, specifier: "%.2f")s")
                        .font(TopoType.mono(13))
                        .foregroundStyle(RidgePalette.creamDim)
                }
            }
            .padding(RidgeMetrics.gutter)
        }
        .ridgeGround()
        .navigationTitle("Topo Gallery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: RidgeMetrics.inset) {
            RidgeSectionLabel(title.uppercased())
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
    NavigationStack { TopoGalleryView() }
}
