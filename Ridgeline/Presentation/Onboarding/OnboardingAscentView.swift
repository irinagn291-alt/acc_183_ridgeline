import SwiftUI

/// Demo-first onboarding: enter the first climb, then watch the profile draw.
public struct OnboardingAscentView: View {
    @Bindable var viewModel: OnboardingAscentViewModel
    let onComplete: () -> Void

    public init(viewModel: OnboardingAscentViewModel, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }

    public var body: some View {
        Group {
            if viewModel.step == 0 {
                entryStep
            } else {
                drawStep
            }
        }
        .ridgeGround()
    }

    private var entryStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                Image("OnboardingAscent")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Topo map of a ridge ascent")

                Text("Log your first climb")
                    .font(TopoType.title(28))
                    .foregroundStyle(RidgePalette.cream)

                Text("Enter a summit and the ridge profile will draw itself.")
                    .font(TopoType.body())
                    .foregroundStyle(RidgePalette.creamDim)

                field("Climb name", text: $viewModel.title, placeholder: "Copper Ridge")
                field("Distance (km)", text: $viewModel.distanceText, placeholder: "10")
                field("Elevation gain (m)", text: $viewModel.gainText, placeholder: "650")
                field("Duration (min)", text: $viewModel.durationText, placeholder: "240")

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(TopoType.body(13))
                        .foregroundStyle(RidgePalette.summit)
                }

                RidgeButton(viewModel.isSaving ? "Saving…" : "Draw the ridge") {
                    Task { @MainActor in
                        _ = await viewModel.continueFromEntry()
                    }
                }
                .disabled(viewModel.isSaving)
            }
            .padding(RidgeMetrics.gutter)
        }
    }

    private var drawStep: some View {
        VStack(spacing: RidgeMetrics.gutter) {
            Spacer(minLength: 12)
            Text("Your ridge")
                .font(TopoType.title(26))
                .foregroundStyle(RidgePalette.cream)
            Text(viewModel.savedAscent?.title ?? "First summit")
                .font(TopoType.mono())
                .foregroundStyle(RidgePalette.summit)

            RidgeProfileView(
                samples: viewModel.profileSamples,
                parallaxEnabled: true,
                animateOnAppear: true
            )
            .padding(.horizontal, RidgeMetrics.gutter)

            Text("Contour lines settle on the climb you just logged.")
                .font(TopoType.body())
                .foregroundStyle(RidgePalette.creamDim)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RidgeMetrics.gutter)

            Spacer()

            RidgeButton("Open journal") {
                viewModel.finish()
                onComplete()
            }
            .padding(.horizontal, RidgeMetrics.gutter)
            .padding(.bottom, RidgeMetrics.gutter)
        }
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            RidgeSectionLabel(label.uppercased())
            TextField(placeholder, text: text)
                .font(TopoType.mono())
                .foregroundStyle(RidgePalette.cream)
                .padding(RidgeMetrics.inset)
                .background(RidgePalette.contours.opacity(0.4))
                .overlay {
                    Rectangle().strokeBorder(RidgePalette.creamFaint, lineWidth: RidgeMetrics.hairline)
                }
        }
    }
}

#Preview {
    OnboardingAscentView(
        viewModel: RidgelineContainer.preview().makeOnboardingViewModel(),
        onComplete: {}
    )
}
