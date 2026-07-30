import SwiftUI

/// Form to log or edit an ascent, with optional gear note.
public struct AscentEditorView: View {
    @Bindable var viewModel: AscentEditorViewModel
    let onClose: () -> Void
    let onSaved: () -> Void

    public init(
        viewModel: AscentEditorViewModel,
        onClose: @escaping () -> Void,
        onSaved: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onClose = onClose
        self.onSaved = onSaved
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RidgeMetrics.gutter) {
                Text(viewModel.isEditing ? "Edit ascent" : "Log ascent")
                    .font(TopoType.title(26))
                    .foregroundStyle(RidgePalette.cream)

                field("Title", text: $viewModel.title, placeholder: "Summit name")
                field("Distance (km)", text: $viewModel.distanceText, placeholder: "10.0")
                field("Elevation gain (m)", text: $viewModel.gainText, placeholder: "650")
                field("Duration (min)", text: $viewModel.durationText, placeholder: "240")

                VStack(alignment: .leading, spacing: 6) {
                    RidgeSectionLabel("DATE")
                    DatePicker(
                        "Climbed at",
                        selection: $viewModel.climbedAt,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .tint(RidgePalette.summit)
                    .colorScheme(.dark)
                }

                if !viewModel.routes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        RidgeSectionLabel("ROUTE")
                        Picker("Route", selection: $viewModel.selectedRouteID) {
                            Text("None").tag(Optional<UUID>.none)
                            ForEach(viewModel.routes) { route in
                                Text(route.name).tag(Optional(route.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(RidgePalette.cream)
                    }
                }

                field("Notes", text: $viewModel.notes, placeholder: "Conditions, pace notes…")
                field("Gear note (optional)", text: $viewModel.gearTitle, placeholder: "Microspikes")
                field("Gear detail", text: $viewModel.gearDetail, placeholder: "When it helped")

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(TopoType.body(13))
                        .foregroundStyle(RidgePalette.summit)
                }

                RidgeButton(viewModel.isSaving ? "Saving…" : "Save ascent") {
                    Task {
                        if await viewModel.save() { onSaved() }
                    }
                }
                .disabled(viewModel.isSaving)
            }
            .padding(RidgeMetrics.gutter)
        }
        .ridgeGround()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { onClose() }
                    .font(TopoType.body())
                    .foregroundStyle(RidgePalette.creamDim)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
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
    NavigationStack {
        AscentEditorView(
            viewModel: RidgelineContainer.preview().makeAscentEditorViewModel(),
            onClose: {},
            onSaved: {}
        )
    }
}
