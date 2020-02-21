import CircleDriver
import Rainbow

class ObstacleTracking {
    private(set) var obstacle: Obstacle

    init(obstacle: Obstacle) {
        self.obstacle = obstacle
    }
    
    func move() {
        obstacle = obstacle.move()
    }
}

public enum SimulationResult: CustomStringConvertible {
    case undefined
    case moving
    case fault(Int)
    case timeout(Int)
    case collision(Int)
    case finished(Int)
    
    public var isMoving: Bool {
        switch self {
        case .moving:
            return true
        default:
            return false
        }
    }
    
    public var description: String {
        switch self {
        case .undefined: return "undefined".red
        case .moving: return "moving".red
        case .fault(let iteration): return "fault (after \(iteration) iterations)".red
        case .timeout(let iteration): return "timeout (after \(iteration) iterations)".red
        case .collision(let iteration): return "collision (after \(iteration) iterations)".red
        case .finished(let iteration): return "finished (after \(iteration) iterations)".green
        }
    }
}

class DriverTracking {
    private(set) var driver: CircleDriverProtocol
    private(set) var color: CircleDriver.Color
    private(set) var circle: Circle
    var result: SimulationResult = .moving
    var stillMoving: Bool { result.isMoving }

    init(driver: CircleDriverProtocol, circle: Circle, color: CircleDriver.Color) {
        self.driver = driver
        self.circle = circle
        self.color = color
    }
    
    func hasReached(point: Point) -> Bool {
        return circle.position.distance(to: point) < circle.radius
    }
    
    func apply(movement: Movement) {
        circle = circle.moved(by: movement)
    }
    
    func mark(as result: SimulationResult) {
        self.result = result
        
        switch result {
        case .collision, .fault, .timeout, .undefined:
            color = .collision
        case .finished:
            color = .finished
        case .moving:
            break
        }
    }
}
