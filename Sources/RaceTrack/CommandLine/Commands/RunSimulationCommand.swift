import Foundation
import SwiftCLI
import Files
import CircleDriver

class RunSimulationCommand: Command {
    let name = "run"
    let shortDescription = "Runs race simulations with provided (or randomised) parameters"

    @Param var count: Int
    @Key("--area", description: "[AUTO-GENERATED] defines area used as race track e.g. '0,0,1000,1000'") var area: Area?
    @Key("--maxStep", description: "[AUTO-GENERATED] defines maximum step for the circle in one movement e.g. '10'") var maximumStep: Step?
    @Key("--obstacles", description: "[AUTO-GENERATED] defines number of obstacles to generate e.g. '5'") var obstaclesCount: Int?
    @Key("--radius", description: "[AUTO-GENERATED] defines the range for radius e.g. '1.0...5.0'") var radiusRange: ClosedRange<Radius>?
    @Key("--animation", description: "defines the file to save simulation animation (SVG) e.g. 'animation.svg'") var animationFile: String?
    @Key("--racetrack", description: "defines the file to save simulation parameters e.g. 'simulation.rct'") var raceTrackFile: String?
    
    let simulator = Simulator()
    let driversProvider = DriversProvider.default

    func execute() throws {
        guard count >= 1 else {
            print("error: ".red + "Wrong number of simulations [\(count)], should be >= 1")
            return
        }
        verbosePrint("Running simulations [\(count)] with parameters:")
        
        // Input parameters
        let area = self.area ?? Defaults.standard.area
        verbosePrint(" *** ".cyan + "Area: " + "\(area)".cyan)
        let radiusRange = self.radiusRange ?? Defaults.standard.bestRadiusRange(for: area)
        verbosePrint(" *** ".cyan + "Range of radius: " + "\(radiusRange)".cyan)
        let obstaclesCount = self.obstaclesCount ?? Defaults.standard.bestObstacleCount(for: area, radius: radiusRange)
        verbosePrint(" *** ".cyan + "Obstacles count: " + "\(obstaclesCount)".cyan)
        let maximumStep = self.maximumStep ?? Defaults.standard.bestMaximumStep(for: radiusRange)
        verbosePrint(" *** ".cyan + "Maximum step length: " + "\(maximumStep)".cyan)
        let stepTime = globalAnimationStepTime ?? Defaults.standard.bestAnimationTime(for: maximumStep, in: area)
        verbosePrint(" *** ".cyan + "Animation step time: " + "\(stepTime)".cyan)
        let maxIterations = globalMaxIterations ?? Defaults.standard.bestMaxIterationsCount(for: maximumStep, in: area)
        verbosePrint(" *** ".cyan + "Iterations limit: " + "\(maxIterations)".cyan)

        // Simulation
        do {
            for index in 1...count {
                print("Simulation #\(index)")
                let raceTrack = try RaceTrackFactory().randomRaceTrack(for: area,
                                                                       radiusRange: radiusRange,
                                                                       obstaclesCount: obstaclesCount,
                                                                       maximumStep: maximumStep,
                                                                       maximumIterations: maxIterations)

                verbosePrint(" *** ".cyan + "Starting circle: " + "\(raceTrack.circle)".cyan)
                verbosePrint(" *** ".cyan + "Destination point: " + "\(raceTrack.destination)".cyan)
                
                let log = simulator.startSimulation(with: driversProvider.drivers, on: raceTrack)
                driversProvider.drivers.forEach({
                    print("[\($0.name.cyan)] Simulation completed with result: " + "\(log.result(for: $0))")
                })
                
                try raceTrackFile.flatMap({ file in
                    let filePath = file.addingStringBeforeFileExtension("\(index)")
                    verbosePrint("Saving race track parameters to \(filePath)")
                    try raceTrack.save(to: filePath)
                })
                
                try animationFile.flatMap({ file in
                    let filePath = file.addingStringBeforeFileExtension("\(index)")
                    verbosePrint("Saving simulation animation to \(filePath)")
                    try log.animation(withStepTime: stepTime).save(to: filePath)
                })
            }
        }
        catch {
            print("error: ".red + "Simulation failed with an error: \(error)")
        }
    }
}


