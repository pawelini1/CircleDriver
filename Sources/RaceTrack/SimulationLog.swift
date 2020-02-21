import Foundation
import CircleDriver

public struct ColorCircle {
    let name: String
    let circle: Circle
    let color: Color
}

extension ColorCircle: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

public class SimulationLog {
    public let raceTrack: RaceTrack
    public private(set) var entries = [[ColorCircle]]()
    private var results = [String: SimulationResult]()
    
    init(raceTrack: RaceTrack) {
        self.raceTrack = raceTrack
    }
    
    public var allCircles: [ColorCircle] {
        entries.flatMap({ $0 }).reduce(into: [ColorCircle]()) { (result, circle) in
            guard result.contains(circle) == false else { return }
            result.append(circle)
        }
    }
    
    public func result(for driver: CircleDriverProtocol) -> SimulationResult {
        return results[driver.name] ?? .undefined
    }
        
    func log(drivers: [DriverTracking], obstacles: [ObstacleTracking], destination: Circle) {
        results = drivers.reduce(into: [String: SimulationResult](), { (result, driver) in
            result[driver.driver.name] = driver.result
        })
        entries.append(
            drivers.map({ ColorCircle(withDriverTracker: $0) }) +
            [ColorCircle(name: "Destination", circle: destination, color: .finished)] +
            obstacles.enumerated().map { ColorCircle(withObstacleTracker: $0.element, at: $0.offset) }
        )
    }
}

extension ColorCircle {
    init(withObstacleTracker tracker: ObstacleTracking, at index: Int) {
        self.init(name: "Obstacles-\(index)", circle: tracker.obstacle.circle, color: .obstacleColor)
    }
    
    init(withDriverTracker tracker: DriverTracking) {
        self.init(name: tracker.driver.name, circle: tracker.circle, color: tracker.color)
    }
}
