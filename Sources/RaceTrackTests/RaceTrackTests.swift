import XCTest
import CircleDriver
@testable import RaceTrack

class RaceTrackTests: XCTestCase {
    func testRandomPointWithExcludedArea() {
        let area = Area(x: 0, y: 0, width: 100, height: 100)
        let excludedArea = Area(x: 40, y: 40, width: 20, height: 20)
        let point = try! Point.random(in: area, excluding: excludedArea, maximumAttemps: Int.max)
        XCTAssertTrue(area.contains(point))
        XCTAssertFalse(excludedArea.contains(point))
    }
    
    func testRandomPointMaximumAttepsReached() {
        let zeroArea = Area(x: 0, y: 0, width: 0, height: 0)
        XCTAssertThrowsError(try Point.random(in: zeroArea,
                                              excluding: zeroArea,
                                              maximumAttemps: 10))
    }
    
    func testRandomPointContainedInGivenArea() {
        let area = Area(x: 0, y: 0, width: 1000, height: 1000)
        let point = Point.random(in: area)
        XCTAssertTrue(area.contains(point))
    }
    
    func testRandomPointForEmptyArea() {
        let area = Area(x: 0, y: 0, width: 0, height: 0)
        let point = Point.random(in: area)
        XCTAssertTrue(point == .zero)
    }
    
    func testCircleWithRadius() {
        let point = Point(10, 10)
        let circle = point.circle(with: 20)
        XCTAssertTrue(circle.position == point)
        XCTAssertTrue(circle.radius == 20)
    }
    
    func testRandomPointWithMinimumDistance() {
        let area = Area(x: 0, y: 0, width: 100, height: 100)
        let destination = Point(10, 10)
        let point = try! Point.random(Point.random(in: area), withMinimumDistanceTo: destination, equal: 70, maximumAttemps: Int.max)
        XCTAssertTrue(point.distance(to: destination) >= 70)
    }
    
    func testRandomPointWithMinimumDistanceButMaximumAttemptsReached() {
        let area = Area(x: 0, y: 0, width: 100, height: 100)
        let destination = Point(10, 10)
        XCTAssertThrowsError(try Point.random(Point.random(in: area), withMinimumDistanceTo: destination, equal: 100, maximumAttemps: 5))
    }
    
    func testRandomMovement() {
        let movement = Movement.random(with: 30)
        XCTAssertTrue((0.0...30).contains(movement.step))
        XCTAssertTrue(Heading.range.contains(movement.heading))
    }
    
    func testRandomMovementWithStep0() {
        let movement = Movement.random(with: 0)
        XCTAssertTrue(movement.step == 0.0)
        XCTAssertTrue(Heading.range.contains(movement.heading))
    }
}
