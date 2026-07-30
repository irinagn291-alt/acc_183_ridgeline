import SwiftUI

/// Horizontal elevation cross-section with linear contour draw and capped parallax.
public struct RidgeProfileView: View {
    private let samples: [ElevationSample]
    private let parallaxEnabled: Bool
    private let animateOnAppear: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawProgress: CGFloat = 0
    @State private var parallax: CGSize = .zero

    public init(
        samples: [ElevationSample],
        parallaxEnabled: Bool = true,
        animateOnAppear: Bool = true
    ) {
        self.samples = samples
        self.parallaxEnabled = parallaxEnabled
        self.animateOnAppear = animateOnAppear
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .bottomLeading) {
                contourGrid(in: size)
                    .offset(x: parallax.width * 0.35, y: parallax.height * 0.2)

                ridgeFill(in: size)
                    .offset(x: parallax.width * 0.6, y: parallax.height * 0.35)

                ridgeStroke(in: size)
                    .offset(x: parallax.width, y: parallax.height)

                summitMark(in: size)
                    .offset(x: parallax.width, y: parallax.height)
            }
            .contentShape(Rectangle())
            .gesture(parallaxGesture)
        }
        .frame(height: RidgeMetrics.profileHeight)
        .clipped()
        .onAppear { startDraw() }
        .onChange(of: samples) { _, _ in startDraw() }
    }

    private func startDraw() {
        let staticDraw = reduceMotion || !animateOnAppear
        if staticDraw {
            drawProgress = 1
            return
        }
        drawProgress = 0
        withAnimation(RidgeMotion.contourDraw(reduceMotion: false)) {
            drawProgress = 1
        }
    }

    private var parallaxGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard parallaxEnabled, !reduceMotion else { return }
                let raw = CGSize(
                    width: value.translation.width / 18,
                    height: value.translation.height / 24
                )
                parallax = RidgeMotion.clampedParallax(x: raw.width, y: raw.height)
            }
            .onEnded { _ in
                guard !reduceMotion else { return }
                withAnimation(RidgeMotion.profileSettle(reduceMotion: false)) {
                    parallax = .zero
                }
            }
    }

    private func contourGrid(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let levels = 5
            for index in 1...levels {
                let y = canvasSize.height * CGFloat(index) / CGFloat(levels + 1)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width * drawProgress, y: y))
                context.stroke(
                    path,
                    with: .color(RidgePalette.contourDim),
                    lineWidth: RidgeMetrics.hairline
                )
            }
        }
    }

    private func ridgePath(in size: CGSize) -> Path {
        guard samples.count >= 2 else { return Path() }
        var path = Path()
        for (index, sample) in samples.enumerated() {
            let x = size.width * sample.progress
            let y = size.height * (1 - sample.elevationNormalized * 0.82) - 8
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }

    private func ridgeFill(in size: CGSize) -> some View {
        let outline = ridgePath(in: size)
        return Canvas { context, canvasSize in
            var fill = outline
            if let last = samples.last {
                fill.addLine(to: CGPoint(x: canvasSize.width * last.progress, y: canvasSize.height))
                fill.addLine(to: CGPoint(x: 0, y: canvasSize.height))
                fill.closeSubpath()
            }
            context.clip(to: Path(CGRect(origin: .zero, size: CGSize(
                width: canvasSize.width * drawProgress,
                height: canvasSize.height
            ))))
            context.fill(fill, with: .color(RidgePalette.contours.opacity(0.45)))
        }
    }

    private func ridgeStroke(in size: CGSize) -> some View {
        ridgePath(in: size)
            .trim(from: 0, to: drawProgress)
            .stroke(RidgePalette.cream, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }

    @ViewBuilder
    private func summitMark(in size: CGSize) -> some View {
        if let peak = samples.max(by: { $0.elevationNormalized < $1.elevationNormalized }),
           drawProgress > 0.92 {
            let x = size.width * peak.progress
            let y = size.height * (1 - peak.elevationNormalized * 0.82) - 8
            Circle()
                .fill(RidgePalette.summit)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
        }
    }
}

#Preview {
    RidgeProfileView(samples: BuildElevationProfileUseCase.demoProfile())
        .padding()
        .ridgeGround()
}
