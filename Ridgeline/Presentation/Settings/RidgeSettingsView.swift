import SwiftUI

/// Units, parallax, gallery link, and destructive reset.
public struct RidgeSettingsView: View {
    @Bindable var viewModel: RidgeSettingsViewModel
    @Bindable var coordinator: RidgelineCoordinator
    let onResetCompleted: () -> Void
    @State private var showContactUs = false

    public init(
        viewModel: RidgeSettingsViewModel,
        coordinator: RidgelineCoordinator,
        onResetCompleted: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.onResetCompleted = onResetCompleted
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                Text("Settings")
                    .font(TopoType.title(24))
                    .foregroundStyle(RidgePalette.cream)

                panel("UNITS") {
                    Picker("Unit system", selection: $viewModel.preferences.unitSystem) {
                        ForEach(RidgeUnitSystem.allCases, id: \.self) { system in
                            Text(system.label).tag(system)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.preferences.unitSystem) { _, _ in
                        viewModel.persist()
                    }
                }

                panel("MOTION") {
                    Toggle("Ridge parallax", isOn: $viewModel.preferences.parallaxEnabled)
                        .tint(RidgePalette.summit)
                        .foregroundStyle(RidgePalette.cream)
                        .onChange(of: viewModel.preferences.parallaxEnabled) { _, _ in
                            viewModel.persist()
                        }
                    Text("Capped at \(Int(RidgeMotion.parallaxBudget)) pt. Off under Reduce Motion.")
                        .font(TopoType.body(12))
                        .foregroundStyle(RidgePalette.creamDim)
                }

                RidgeButton("Topo gallery", accent: false) {
                    coordinator.openGallery()
                }

                RidgeButton("Contact Us", accent: false) {
                    showContactUs = true
                }

                panel("ABOUT") {
                    Text("Ridgeline")
                        .font(TopoType.bodyBold())
                        .foregroundStyle(RidgePalette.cream)
                    Text("Elevation journal · Ordnance Survey topo.")
                        .font(TopoType.body(13))
                        .foregroundStyle(RidgePalette.creamDim)
                    Text("com.ridgeline.ascent")
                        .font(TopoType.mono(12))
                        .foregroundStyle(RidgePalette.creamFaint)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(TopoType.body(13))
                        .foregroundStyle(RidgePalette.summit)
                }

                RidgeButton(viewModel.isResetting ? "Resetting…" : "Reset journal", accent: true) {
                    viewModel.confirmReset = true
                }
                .disabled(viewModel.isResetting)
            }
            .padding(RidgeMetrics.gutter)
        }
        .ridgeGround()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
        .sheet(isPresented: $showContactUs) {
            NavigationStack {
                ContactUsWebView()
            }
        }
        .confirmationDialog(
            "Delete every ascent, route and gear note?",
            isPresented: $viewModel.confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset journal", role: .destructive) {
                Task {
                    if await viewModel.resetJournal() {
                        onResetCompleted()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
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
        RidgeSettingsView(
            viewModel: RidgelineContainer.preview().makeSettingsViewModel(),
            coordinator: RidgelineCoordinator(),
            onResetCompleted: {}
        )
    }
}
