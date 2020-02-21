import XCTest
@testable import CircleDriver

class CircleDriverTests: XCTestCase {
    func testHeadingZero() {
        assert(Heading(towards: .zero, from: .zero) == Heading.up)
    }
    
    func testHeadingVerticalAndHorizontal() {
        assert(Heading(towards: Point(0.0, 100.0), from: Point.zero) == Heading.up)
        assert(Heading(towards: Point(0.0, -100.0), from: Point.zero) == Heading.down)
        assert(Heading(towards: Point(100.0, 0.0), from: Point.zero) == Heading.right)
        assert(Heading(towards: Point(-100.0, 0.0), from: Point.zero) == Heading.left)
    }
    
    func testHeadingAlmostVertical() {
        assert(Heading(towards: Point(1, 100.0), from: Point.zero) < 0.02)
        assert(Heading(towards: Point(-1, 100.0), from: Point.zero) > -0.02)
        assert(Heading(towards: Point(1, -100.0), from: Point.zero) > 3.12)
        assert(Heading(towards: Point(-1, -100.0), from: Point.zero) < -3.12)
    }
    
    func testHeading45Degrees() {
        assert(Heading(towards: Point(100.0, 100.0), from: Point.zero) == Double.pi / 4.0)
        assert(Heading(towards: Point(-100.0, 100.0), from: Point.zero) == -Double.pi / 4.0)
        assert(Heading(towards: Point(100.0, -100.0), from: Point.zero) == 3 * Double.pi / 4.0)
        assert(Heading(towards: Point(-100.0, -100.0), from: Point.zero) == -3 * Double.pi / 4.0)
    }

    func testMovementInit() {
        assert(Movement(step: 1, heading: .up).step == 1)
        assert(Movement(step: 1, heading: .up).heading == .up)
        assert(Movement(step: 1, heading: Heading.pi * 2).heading == .up)
        assert(Movement(step: 1, heading: Heading.pi * 4).heading == .up)
        assert(Movement(step: 1, heading: -Heading.pi * 2).heading == .up)
        assert(Movement(step: 1, heading: -Heading.pi * 4).heading == .up)
        assert(Movement(step: 1, heading: Heading.pi2 * 3).heading == .left)
        assert(Movement(step: 1, heading: -Heading.pi2 * 3).heading == .right)
    }
    
    func testArea() {
        let area = Area(x: 5, y: 10, width: 30, height: 40)
        
        assert(area.x == 5)
        assert(area.y == 10)
        assert(area.width == 30)
        assert(area.height == 40)
        
        assert(area.maxX == 35)
        assert(area.maxY == 50)
        assert(area.minX == 5)
        assert(area.minY == 10)
        
        assert(area.diagonal == 50)
        
        assert(area.contains(Point(5, 10)))
        assert(area.contains(Point(35, 50)))
        assert(area.contains(Point(20, 20)))
        
        assert(area.subarea(withPercentage: 1.0) == area)
        assert(area.subarea(withPercentage: 0.0) == Area(x: 20, y: 30, width: 0, height: 0))
        assert(area.subarea(withPercentage: 0.5) == Area(x: 12.5, y: 20, width: 15, height: 20))
    }
    
    func testCircleInit() {
        let circle = Circle(position: Point(20, 20), radius: 10)
        
        assert(circle.radius == 10)
        assert(circle.position == Point(20, 20))
    }
    
    func testCircleMovement() {
        let circle = Circle(position: Point(20, 20), radius: 10)
        
        assert(circle.moved(by: .noMovement) == circle)
        assert(circle.moved(by: Movement(step: 10, heading: .up)).position == Point(20, 30))
        assert(circle.moved(by: Movement(step: 10, heading: .down)).position == Point(20, 10))
        assert(circle.moved(by: Movement(step: 10, heading: .left)).position == Point(10, 20))
        assert(circle.moved(by: Movement(step: 10, heading: .right)).position == Point(30, 20))
    }
    
    func testObstacleInit() {
        let circle = Circle(position: Point(20, 20), radius: 10)
        let movement = Movement(step: 10, heading: .up)
        let obstacle = Obstacle(circle: circle, movement: movement)

        assert(obstacle.circle == circle)
        assert(obstacle.movement == movement)
    }
    
    func testObstacleMovement() {
        let circle = Circle(position: Point(20, 20), radius: 10)
        var moved: Obstacle
        
        moved = Obstacle(circle: circle, movement: .noMovement)
        assert(moved == moved)
        
        moved = Obstacle(circle: circle, movement: Movement(step: 10, heading: .up)).move()
        assert(moved.circle.position == Point(20, 30))
        
        moved = Obstacle(circle: circle, movement: Movement(step: 10, heading: .down)).move()
        assert(moved.circle.position == Point(20, 10))
        
        moved = Obstacle(circle: circle, movement: Movement(step: 10, heading: .left)).move()
        assert(moved.circle.position == Point(10, 20))
        
        moved = Obstacle(circle: circle, movement: Movement(step: 10, heading: .right)).move()
        assert(moved.circle.position == Point(30, 20))
    }
    
    func testPointsDistance() {
        let point = Point.zero
        let reallySmallValue = 0.001
        let valuesRangeCloseTo: (Double) -> ClosedRange<Double> = { $0-reallySmallValue...$0+reallySmallValue }

        XCTAssert(valuesRangeCloseTo(0.0).contains(point.distance(to: .zero)))
        
        XCTAssert(valuesRangeCloseTo(10).contains(point.distance(to: Point(0, 10))))
        XCTAssert(valuesRangeCloseTo(10).contains(point.distance(to: Point(0, -10))))
        XCTAssert(valuesRangeCloseTo(10).contains(point.distance(to: Point(10, 0))))
        XCTAssert(valuesRangeCloseTo(10).contains(point.distance(to: Point(-10, 0))))
        
        XCTAssert(valuesRangeCloseTo(14.1421).contains(point.distance(to: Point(10, 10))))
        XCTAssert(valuesRangeCloseTo(14.1421).contains(point.distance(to: Point(-10, 10))))
        XCTAssert(valuesRangeCloseTo(14.1421).contains(point.distance(to: Point(10, -10))))
        XCTAssert(valuesRangeCloseTo(14.1421).contains(point.distance(to: Point(-10, -10))))
    }
    
    func testPointMovement() {
        let point = Point.zero
        let maximumStep = 10.0
        let reallySmallDistance = 0.001
        XCTAssert(point.moved(by: .noMovement) == .zero)
        
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .up)).distance(to: Point(0.0, maximumStep)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .down)).distance(to: Point(0.0, -maximumStep)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .right)).distance(to: Point(maximumStep, 0.0)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .left)).distance(to: Point(-maximumStep, 0.0)) < reallySmallDistance)
        
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .pi4)).distance(to: Point(7.071, 7.071)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: -.pi4)).distance(to: Point(-7.071, 7.071)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: -.pi4 - .pi2)).distance(to: Point(-7.071, -7.071)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .pi4 + .pi2)).distance(to: Point(7.071, -7.071)) < reallySmallDistance)
        
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .pi8)).distance(to: Point(3.8268, 9.2387)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: -.pi8)).distance(to: Point(-3.8268, 9.2387)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: -.pi8 - .pi2)).distance(to: Point(-9.2387, -3.8268)) < reallySmallDistance)
        XCTAssert(point.moved(by: Movement(step: maximumStep, heading: .pi8 + .pi2)).distance(to: Point(9.2387, -3.8268)) < reallySmallDistance)
    }
}
