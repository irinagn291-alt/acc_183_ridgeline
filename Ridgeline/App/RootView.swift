import SwiftUI

/// Assembly point: onboarding gate, navigation stack, FAB sheet.
public struct RootView: View {
    @State private var coordinator = RidgelineCoordinator()
    @State private var showOnboarding: Bool?
    @State private var launchError: String?
    @State private var dashboardViewModel: ProfileDashboardViewModel?
    @State private var onboardingViewModel: OnboardingAscentViewModel?

    private let container: RidgelineContainer

    public init(container: RidgelineContainer) {
        self.container = container
    }

    public var body: some View {
        Group {
            if showOnboarding == true, let onboardingViewModel {
                OnboardingAscentView(viewModel: onboardingViewModel) {
                    ensureDashboard()
                    showOnboarding = false
                }
            } else if showOnboarding == false, let dashboardViewModel {
                mainStack(dashboard: dashboardViewModel)
            } else {
                launchState
            }
        }
        .task { await decideFirstScreen() }
    }

    private func mainStack(dashboard: ProfileDashboardViewModel) -> some View {
        NavigationStack(path: $coordinator.path) {
            ProfileDashboardView(
                viewModel: dashboard,
                coordinator: coordinator
            )
            .navigationDestination(for: RidgelineRoute.self, destination: destination)
        }
        .tint(RidgePalette.summit)
        .sheet(item: $coordinator.sheet, content: sheet)
        .onChange(of: coordinator.sheet) { _, newValue in
            if newValue == nil {
                Task { await dashboard.refresh() }
            }
        }
    }

    private var launchState: some View {
        VStack(spacing: RidgeMetrics.gutter) {
            if let launchError {
                RidgeEmptyState(
                    title: "Journal unavailable",
                    detail: "Ridgeline could not open your saved climbs. Try again to keep your data intact."
                )
                Text(launchError)
                    .font(TopoType.body(13))
                    .foregroundStyle(RidgePalette.creamFaint)
                RidgeButton("Try again") {
                    self.launchError = nil
                    Task { await decideFirstScreen() }
                }
            } else {
                RidgeLoadingState("Preparing the contour map…")
            }
        }
        .padding(RidgeMetrics.gutter)
        .ridgeGround()
    }

    @ViewBuilder
    private func destination(_ route: RidgelineRoute) -> some View {
        switch route {
        case .charts:
            OnceViewModel(make: { container.makeChartsViewModel() }) { viewModel in
                RidgeChartsView(viewModel: viewModel)
            }
        case .insights:
            OnceViewModel(make: { container.makeInsightsViewModel() }) { viewModel in
                RidgeInsightsView(viewModel: viewModel)
            }
        case .history:
            OnceViewModel(make: { container.makeHistoryViewModel() }) { viewModel in
                AscentHistoryView(viewModel: viewModel, coordinator: coordinator)
            }
        case .settings:
            OnceViewModel(make: { container.makeSettingsViewModel() }) { viewModel in
                RidgeSettingsView(
                    viewModel: viewModel,
                    coordinator: coordinator,
                    onResetCompleted: {
                        dashboardViewModel = nil
                        onboardingViewModel = container.makeOnboardingViewModel()
                        showOnboarding = true
                        coordinator.popToRoot()
                    }
                )
            }
        case .gallery:
            TopoGalleryView()
        case .editAscent(let id):
            OnceViewModel(make: { container.makeAscentEditorViewModel(ascentID: id) }) { viewModel in
                AscentEditorView(
                    viewModel: viewModel,
                    onClose: { coordinator.pop() },
                    onSaved: { coordinator.pop() }
                )
            }
        }
    }

    @ViewBuilder
    private func sheet(_ sheet: RidgelineSheet) -> some View {
        switch sheet {
        case .logAscent:
            NavigationStack {
                OnceViewModel(make: { container.makeAscentEditorViewModel(ascentID: nil) }) { viewModel in
                    AscentEditorView(
                        viewModel: viewModel,
                        onClose: { coordinator.dismissSheet() },
                        onSaved: { coordinator.dismissSheet() }
                    )
                }
            }
        case .editAscent(let id):
            NavigationStack {
                OnceViewModel(make: { container.makeAscentEditorViewModel(ascentID: id) }) { viewModel in
                    AscentEditorView(
                        viewModel: viewModel,
                        onClose: { coordinator.dismissSheet() },
                        onSaved: { coordinator.dismissSheet() }
                    )
                }
            }
        }
    }

    private func ensureDashboard() {
        if dashboardViewModel == nil {
            dashboardViewModel = container.makeDashboardViewModel()
        }
    }

    private func decideFirstScreen() async {
        guard showOnboarding == nil else { return }
        #if targetEnvironment(simulator)
        try? await SimulatorTrailSeeder(
            routeRepository: container.routeRepository,
            ascentRepository: container.ascentRepository,
            gearRepository: container.gearRepository
        ).seedIfEmpty()
        container.onboardingStore.markOnboardingComplete()
        ensureDashboard()
        await dashboardViewModel?.refresh()
        showOnboarding = false
        #else
        if container.onboardingStore.hasCompletedOnboarding() {
            ensureDashboard()
            await dashboardViewModel?.refresh()
            showOnboarding = false
            return
        }
        do {
            let empty = try await container.journalIsEmpty()
            if empty {
                if onboardingViewModel == nil {
                    onboardingViewModel = container.makeOnboardingViewModel()
                }
                showOnboarding = true
            } else {
                container.onboardingStore.markOnboardingComplete()
                ensureDashboard()
                await dashboardViewModel?.refresh()
                showOnboarding = false
            }
        } catch {
            launchError = error.localizedDescription
        }
        #endif
    }
}

#Preview("Root") {
    RootView(container: RidgelineContainer.preview())
}
