import XCTest
@testable import Ridgeline

final class RidgeMotionTests: XCTestCase {
    func test_givenParallaxBudget_whenClampingLargeOffset_thenStaysInsideBudget() {
        // Given
        let rawX: CGFloat = 100
        let rawY: CGFloat = -80

        // When
        let clamped = RidgeMotion.clampedParallax(x: rawX, y: rawY)

        // Then
        XCTAssertEqual(clamped.width, RidgeMotion.parallaxBudget)
        XCTAssertEqual(clamped.height, -RidgeMotion.parallaxBudget)
    }

    func test_givenReduceMotion_whenRequestingContourDraw_thenAnimationIsNil() {
        // Given / When
        let animation = RidgeMotion.contourDraw(reduceMotion: true)

        // Then
        XCTAssertNil(animation)
    }

    func test_givenMotionAllowed_whenRequestingContourDraw_thenAnimationExists() {
        // Given / When
        let animation = RidgeMotion.contourDraw(reduceMotion: false)

        // Then
        XCTAssertNotNil(animation)
    }
}
