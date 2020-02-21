import CircleDriver

public class JustGoTowardsCircleDriver: CircleDriverProtocol {
    public var name: String {
        return "JustGoTowardsCircleDriver at \(stepPercentage) of max speed"
    }

    private let stepPercentage: Double
    
    public init(stepPercentage: Double = 1.0) {
        self.stepPercentage = stepPercentage
    }
        
    public func movement(for circle: Circle,
                         goingTo destination: Point,
                         withMaximumStep maximumStep: Step,
                         avoidingCollisionsWith obstacles: [Obstacle]) -> Movement {
        return Movement(step: maximumStep * stepPercentage, heading: .init(towards: destination, from: circle.position))
    }
}
