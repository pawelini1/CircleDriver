import Foundation
import CircleDriver

struct Defaults {
    static let standard = Defaults(area: Area(x: 0, y: 0, width: 1000, height: 1000),
                                   obstaclesSurfaceToAreaSurfaceFactor: 0.1,
                                   radiusToAreaLengthFactorRange: 0.005...0.015,
                                   maximumStepLengthToMinRadiusFactor: 0.5,
                                   maximumAnimationTime: 5.0,
                                   iterationsToMinimumStepsFactor: 10.0)
    
    public let area: Area
    private let obstaclesSurfaceToAreaSurfaceFactor: Double
    private let radiusToAreaLengthFactorRange: ClosedRange<Double>
    private let maximumStepLengthToMinRadiusFactor: Double
    private let maximumAnimationTime: Double
    private let iterationsToMinimumStepsFactor: Double

    init(area: Area,
         obstaclesSurfaceToAreaSurfaceFactor: Double,
         radiusToAreaLengthFactorRange: ClosedRange<Double>,
         maximumStepLengthToMinRadiusFactor: Double,
         maximumAnimationTime: Double,
         iterationsToMinimumStepsFactor: Double) {
        self.area = area
        self.obstaclesSurfaceToAreaSurfaceFactor = obstaclesSurfaceToAreaSurfaceFactor
        self.radiusToAreaLengthFactorRange = radiusToAreaLengthFactorRange
        self.maximumStepLengthToMinRadiusFactor = maximumStepLengthToMinRadiusFactor
        self.maximumAnimationTime = maximumAnimationTime
        self.iterationsToMinimumStepsFactor = iterationsToMinimumStepsFactor
    }

    func bestRadiusRange(for area: Area) -> ClosedRange<Radius> {
        let minLength = min(area.width, area.height)
        return (minLength * radiusToAreaLengthFactorRange.lowerBound)...(minLength * radiusToAreaLengthFactorRange.upperBound)
    }
    
    func bestMaximumStep(for radius: ClosedRange<Radius>) -> Step {
        return radius.lowerBound * maximumStepLengthToMinRadiusFactor
    }
    
    func bestAnimationTime(for maximumStep: Step, in area: Area) -> Double {
        return maximumAnimationTime / (area.diagonal / maximumStep)
    }
    
    func bestMaxIterationsCount(for maximumStep: Step, in area: Area) -> Int {
        return Int((area.diagonal / maximumStep) * iterationsToMinimumStepsFactor)
    }
    
    func bestObstacleCount(for area: Area, radius: ClosedRange<Radius>) -> Int {
        let surface = area.width * area.height
        let maxCircleSurface = Double.pi * pow(radius.upperBound, 2)
        return Int(surface * obstaclesSurfaceToAreaSurfaceFactor / maxCircleSurface)
    }
}
