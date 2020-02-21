import Foundation

public typealias Color = String

public extension Color {
    static let red: Color = "red"
    static let brown: Color = "brown"
    static let indigo: Color = "indigo"
    static let purple: Color = "purple"
    static let lawngreen: Color = "lawngreen"
    static let plum: Color = "plum"
    static let yellow: Color = "yellow"
    static let slategrey: Color = "slategrey"
    static let orange: Color = "orange"
    static let thistle: Color = "thistle"
    static let greenyellow: Color = "greenyellow"
    static let lightblue: Color = "lightblue"
    
    static let driverColors: [Color] = [.red, .brown, .indigo, .purple, .lawngreen, .plum, .yellow, .slategrey, .orange, .thistle, .greenyellow, .lightblue]
}

public typealias Step = Double // Distance travelled in one iteration

public typealias Heading = Double // In radians, <-𝛑 ... 𝛑>

public extension Heading {
    init(towards to: Point, from: Point) {
        switch ((to.x - from.x), (to.y - from.y)) {
        case (0.0, 0.0):
            self = .up
        case (0.0, let y):
            self = y > 0.0 ? .up : .down
        case (let x, 0.0):
            self = x > 0.0 ? .right : .left
        case (let x, let y) where x > 0.0 && y > 0.0:
            self = atan(abs(x) / abs(y))
        case (let x, let y) where x < 0.0 && y > 0.0:
            self = -atan(abs(x) / abs(y))
        case (let x, let y) where x > 0.0 && y < 0.0:
            self = Double.pi - atan(abs(x) / abs(y))
        case (let x, let y) where x < 0.0 && y < 0.0:
            self = -Double.pi + atan(abs(x) / abs(y))
        default:
            fatalError()
        }
    }
}

public extension Heading {
    static let pi2 = pi / 2.0
    static let pi4 = pi / 4.0
    static let pi8 = pi / 8.0

    static let up = 0.0
    static let down = pi
    static let left = -pi2
    static let right = pi2
    
    static let range = -Heading.pi...Heading.pi
}

public struct Movement: Equatable, CustomStringConvertible {
    public static let noMovement = Movement(step: 0.0, heading: .up)
    
    public let step: Step
    public let heading: Heading
    
    public var description: String { "(\(step), \(heading))" }

    public init(step: Step, heading: Heading) {
        self.step = step
        self.heading = heading.remainder(dividingBy: Heading.pi * 2)
    }
}

public struct Point: Equatable, CustomStringConvertible {
    public static let zero = Point(0.0, 0.0)
    public let x: Double
    public let y: Double
    
    public var description: String { "(\(x), \(y))" }
    
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    public func distance(to point: Point) -> Double {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    public func moved(by movement: Movement) -> Point {
        let step = movement.step
        return Point(x + sin(movement.heading) * step, y + cos(movement.heading) * step)
    }
}

public struct Area: Equatable, CustomStringConvertible {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    public var minX: Double { x }
    public var maxX: Double { x + width }
    public var minY: Double { y }
    public var maxY: Double { y + height }

    public var diagonal: Double { sqrt(pow(width, 2) + pow(height, 2)) }

    public var description: String { "(\(x), \(y), \(width), \(height))" }
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public func contains(_ point: Point) -> Bool {
        return (minX...maxX).contains(point.x) && (minY...maxY).contains(point.y)
    }
    
    public func subarea(withPercentage percentage: Double) -> Area {
        let percentage = max(0.0, min(1.0, percentage))
        let newWidth = width * percentage
        let newHeight = height * percentage
        return Area(x: x + (width - newWidth) / 2.0,
                    y: y + (height - newHeight) / 2.0,
                    width: newWidth,
                    height: newHeight)
    }
}

public typealias Radius = Double

public struct Circle: Equatable, CustomStringConvertible {
    public let position: Point
    public let radius: Radius
    
    public var description: String { "(\(position), \(radius))" }

    public init(position: Point, radius: Radius) {
        self.position = position
        self.radius = radius
    }
    
    public func moved(by movement: Movement) -> Circle {
        return Circle(position: position.moved(by: movement), radius: radius)
    }
}

public struct Obstacle: Equatable, CustomStringConvertible {
    public let circle: Circle
    public let movement: Movement
    
    public var description: String { "(\(circle), \(movement))" }

    public init(circle: Circle, movement: Movement) {
        self.circle = circle
        self.movement = movement
    }
    
    public func move() -> Obstacle {
        return Obstacle(circle: circle.moved(by: movement), movement: movement)
    }
}

extension Area: Codable {}
extension Circle: Codable {}
extension Obstacle: Codable {}
extension Point: Codable {}
extension Movement: Codable {}

public protocol CircleDriverProtocol {
    var name: String { get }

    func movement(for circle: Circle,
                  goingTo destination: Point,
                  withMaximumStep maximumStep: Step,
                  avoidingCollisionsWith obstacles: [Obstacle]) -> Movement
}
