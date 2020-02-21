import SwiftCLI
import CircleDriver
import Foundation
import Files
import Rainbow

class RerunSimulationCommand: Command {
    let name = "rerun"
    let shortDescription = "Runs the simulation once again with provided race track"
    
    @Key("--animation", description: "defines the file to save simulation animation (SVG) e.g. 'animation.svg'") var animationFile: String?
    @Key("--racetrack", description: "[REQUIRED] defines the file to load simulation parameters e.g. 'simulation.rct'") var raceTrackFile: String?
    @Flag("--open", description: "defines whether to open the animation after the simulation") var shouldOpenAnimation: Bool
    
    let simulator = Simulator()
    let driversProvider = DriversProvider.default
    
    func execute() throws {
        guard let raceTrackFile = raceTrackFile else {
            print("error: ".red + "Missing --racetrack parameter with the path to file with simulation parameters")
            return
        }
        
        do {
            verbosePrint("Re-running simulation with parameters from \(raceTrackFile)")

            let raceTrack = try RaceTrack.load(from: raceTrackFile)
            let stepTime = globalAnimationStepTime ?? Defaults.standard.bestAnimationTime(for: raceTrack.maximumStep, in: raceTrack.area)

            verbosePrint(" *** ".cyan + "Area: " + "\(raceTrack.area)".cyan)
            verbosePrint(" *** ".cyan + "Obstacles count: " + "\(raceTrack.obstacles.count)".cyan)
            verbosePrint(" *** ".cyan + "Maximum step length: " + "\(raceTrack.maximumStep)".cyan)
            verbosePrint(" *** ".cyan + "Animation step time: " + "\(stepTime)".cyan)
            verbosePrint(" *** ".cyan + "Iterations limit: " + "\(raceTrack)".cyan)
            verbosePrint(" *** ".cyan + "Starting circle: " + "\(raceTrack.circle)".cyan)
            verbosePrint(" *** ".cyan + "Destination point: " + "\(raceTrack.destination)".cyan)

            let log = simulator.startSimulation(with: driversProvider.drivers, on: raceTrack)
            driversProvider.drivers.forEach({
                print("[\($0.name.cyan)] Simulation completed with result: " + "\(log.result(for: $0))")
            })
            
            try animationFile.flatMap({ file in
                verbosePrint("Saving simulation animation to \(file)")
                try log.animation(withStepTime: stepTime).save(to: file)
                if shouldOpenAnimation {
                    verbosePrint("Opening simulation animation ...")
                    try Task.run("open", file)
                }
            })
        } catch {
            print("error: ".red + "Simulation failed with an error: \(error)")
        }
    }
}
