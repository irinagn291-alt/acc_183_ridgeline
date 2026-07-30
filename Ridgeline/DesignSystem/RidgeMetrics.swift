import SwiftUI

/// Geometry tokens for the topo layout.
public enum RidgeMetrics {
    public static let gutter: CGFloat = 16
    public static let inset: CGFloat = 12
    public static let hairline: CGFloat = 1
    public static let fabSize: CGFloat = 56
    public static let profileHeight: CGFloat = 220
    public static let heroHeight: CGFloat = 160
    public static let corner: CGFloat = 4
}

extension View {
    public func ridgeGround() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RidgePalette.ground.ignoresSafeArea())
    }
}
