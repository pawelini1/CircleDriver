import CircleDriver

public typealias SVGAnimation = String

public class AnimationBuilder {
    private let stepTime: Double

    public init(stepTime: Double) {
        self.stepTime = stepTime
    }
    
    public func buildAnimation(for log: SimulationLog) -> SVGAnimation {
        let raceTrack = log.raceTrack
        let circles = log.allCircles
            .map({ self.buildCircleAnimation(for: $0, with: log) })
            .joined(separator: "\n")
        return
"""
<svg width="\(raceTrack.area.width)" height="\(raceTrack.area.height)" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <rect width="\(raceTrack.area.width)" height="\(raceTrack.area.height)" fill="\(Color.background)" />
""" + circles +
"""
</svg>
"""
    }
    
    private func buildCircleAnimation(for circle: ColorCircle, with log: SimulationLog) -> String {
        let pairs = log.entries
            .map({ $0.first(where: { $0.name == circle.name }) })
            .compactMap({ $0 })
            .enumerated()
            .map({
"""
\n        <animateMotion begin="\(stepTime * Double($0.offset))s" dur="0s" path="M\($0.element.circle.position.x),\($0.element.circle.position.y) L\($0.element.circle.position.x),\($0.element.circle.position.y)" />
        <animate attributeName="fill" values="\($0.element.color)" begin="\(stepTime * Double($0.offset))s" dur="0s" fill="freeze"/>


"""         })
            .joined(separator: "")
        return
"""
    \n    <circle id="\(circle.name)" r="\(circle.circle.radius)" fill="\(circle.color)" stroke="white" stroke-width="\(max(1.0, circle.circle.radius * 0.1))">
""" + pairs +
"""
\n    </circle>
"""
    }
}
