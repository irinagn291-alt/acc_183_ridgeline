import SwiftUI

/// Keeps one ViewModel instance for a navigation destination across parent re-renders.
struct OnceViewModel<Model: AnyObject, Content: View>: View {
    @State private var model: Model?
    private let make: () -> Model
    private let content: (Model) -> Content

    init(
        make: @escaping () -> Model,
        @ViewBuilder content: @escaping (Model) -> Content
    ) {
        self.make = make
        self.content = content
    }

    var body: some View {
        Group {
            if let model {
                content(model)
            } else {
                RidgeLoadingState("Preparing the contour map…")
                    .ridgeGround()
                    .task { model = make() }
            }
        }
        .onAppear {
            if model == nil {
                model = make()
            }
        }
    }
}
