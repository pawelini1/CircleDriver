import CircleDriver

public class RaceTrackFactory {
    public init() {}
    
    public func randomRaceTrack(for area: Area,
                                radiusRange: ClosedRange<Radius>,
                                obstaclesCount: Int,
                                maximumStep: Step,
                                maximumIterations: Int) throws -> RaceTrack {
        let circle = Circle(position: try .random(in: area, excluding: area.subarea(withPercentage: 0.7)),
                            radius: .random(in: radiusRange))
        let obstacles = try (0..<obstaclesCount).map { _ -> Obstacle in
            let position = try Point.random(Point.random(in: area), withMinimumDistanceTo: circle.position, equal: area.diagonal * 0.1)
            let circle = Circle(position: position, radius: .random(in: radiusRange))
            return Obstacle(circle: circle, movement: .random(with: maximumStep))
        }
        let destination: Point = try .random(try .random(in: area, excluding: area.subarea(withPercentage: 0.7)),
                                             withMinimumDistanceTo: circle.position,
                                             equal: area.diagonal * 0.5)
        return RaceTrack(area: area,
                         circle: circle,
                         obstacles: obstacles,
                         destination: destination,
                         maximumStep: maximumStep,
                         maximumIterations: maximumIterations)
    }
}
