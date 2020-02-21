import CircleDriver

public final class RaceTrack {
    public let area: Area
    public let circle: Circle
    public private(set) var obstacles: [Obstacle]
    public let destination: Point
    public let maximumStep: Step
    public let maximumIterations: Int

    public init(area: Area, circle: Circle, obstacles: [Obstacle], destination: Point, maximumStep: Step, maximumIterations: Int) {
        self.area = area
        self.circle = circle
        self.obstacles = obstacles
        self.destination = destination
        self.maximumStep = maximumStep
        self.maximumIterations = maximumIterations
    }
}

extension RaceTrack: Codable {}
