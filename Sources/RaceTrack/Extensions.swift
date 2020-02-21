import Foundation
import CircleDriver
import Files

public extension Point {
    enum Error: Swift.Error {
        case maximumAttempsReached(Int)
    }
    
    func circle(with radius: Radius) -> Circle {
        return Circle(position: self, radius: radius)
    }
    
    static func random(in area: Area) -> Point {
        return Point(Double.random(in: 0.0...area.width),
                     Double.random(in: 0.0...area.height))
    }
    
    static func random(in area: Area, excluding: Area, maximumAttemps: Int = 100) throws -> Point {
        var point: Point
        var attemps = 0
        repeat {
            point = .random(in: area)
            attemps += 1
            if attemps == maximumAttemps {
                throw Error.maximumAttempsReached(maximumAttemps)
            }
        } while excluding.contains(point)
        return point
    }
    
    static func random(_ pointsProvider: @autoclosure () throws -> Point, withMinimumDistanceTo destination: Point, equal distance: Double, maximumAttemps: Int = 100) throws -> Point {
                var point: Point
        var attemps = 0
        repeat {
            point = try pointsProvider()
            attemps += 1
            if attemps == maximumAttemps {
                throw Error.maximumAttempsReached(maximumAttemps)
            }
        } while point.distance(to: destination) < distance
        return point

    }
}

public extension Movement {
    static func random(with maximumStep: Step) -> Movement {
        return Movement(step: Step.random(in: 0.0...maximumStep),
                        heading: Heading.random(in: Heading.range))
    }
}

internal extension Color {
    static let obstacleColor: Color = "white"
    static let collision: Color = "black"
    static let finished: Color = "magenta"
    static let background: Color = "blue"
}

extension File {
    static func createIfNeeded(at path: String) throws -> File {
        do {
            return try File(path: path)
        } catch is LocationError {
            try FileManager.default.createDirectory(atPath: path.folderPath(),
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            return try File(path: path)
        }
    }
}

extension RaceTrack {
    func save(to filePath: String) throws {
        let file = try File.createIfNeeded(at: filePath)
        let data = try JSONEncoder().encode(self)
        try file.write(data)
    }
    
    static func load(from filePath: String) throws -> RaceTrack {
        let file = try File(path: filePath)
        return try JSONDecoder().decode(RaceTrack.self, from: try file.read())
    }
}

extension SVGAnimation {
    func save(to filePath: String) throws {
        let file = try File.createIfNeeded(at: filePath)
        try file.write(self, encoding: .utf8)
    }
}

extension SimulationLog {
    func animation(withStepTime stepTime: Step) -> SVGAnimation {
        let animationBuilder = AnimationBuilder(stepTime: stepTime)
        return animationBuilder.buildAnimation(for: self)
    }
}

extension String {
    func addingStringBeforeFileExtension(_ string: String) -> String {
        let components = split(separator: ".")
        guard components.count > 1 else { return self + string }
        return components.dropLast().joined() + string + "." + components.last!
    }
    
    func folderPath() -> String {
        let components = self.components(separatedBy: "/")
        guard components.count > 1 else { return self }
        return components.dropLast().joined(separator: "/")
    }
}
