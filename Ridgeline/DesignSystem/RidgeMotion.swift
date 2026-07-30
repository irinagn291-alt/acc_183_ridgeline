import Foundation
import SwiftUI

/// Contour draw and parallax motion for the ridge profile.
///
/// Contour lines draw with a linear timing curve — no ease-in/out overshoot.
/// Under Reduce Motion every animation collapses to a static state.
public enum RidgeMotion {
    /// Maximum parallax offset in points.
    public static let parallaxBudget: CGFloat = 12
    /// Contour stroke draw duration.
    public static let contourDrawDuration: Double = 1.15
    /// Profile fill settle duration after contours finish.
    public static let profileSettleDuration: Double = 0.35

    /// Linear contour reveal. Nil when Reduce Motion is on (caller shows full path).
    public static func contourDraw(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .linear(duration: contourDrawDuration)
    }

    /// Soft settle for secondary UI, still linear for topography feel.
    public static func profileSettle(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .linear(duration: profileSettleDuration)
    }

    /// Digits rolling over. Paired with `contentTransition(.numericText())`.
    public static func numberRoll(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .linear(duration: 0.2)
    }

    /// Clamps a drag-derived parallax offset to the budget.
    public static func clampedParallax(x: CGFloat, y: CGFloat) -> CGSize {
        CGSize(
            width: max(-parallaxBudget, min(parallaxBudget, x)),
            height: max(-parallaxBudget, min(parallaxBudget, y))
        )
    }
}
