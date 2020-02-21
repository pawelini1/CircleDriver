import SwiftCLI

private let globalAnimationStepTimeKey = Key<Double>("--stepTime", description: "[AUTO-GENERATED] defines the time of one iteration of simulation in seconds e.g. '0.05'")
private let globalMaxIterationsKey = Key<Int>("--iterationsLimit", description: "[AUTO-GENERATED] defines the maximum number of iterations in simulation e.g. '1000'")
private let verboseFlag = Flag("-v", "--verbose", description: "enables printing more precise log messages")

public class CommandLine {
    private let cli: CLI
    public init() {
        self.cli = CLI(name: "racetrack",
                       version: "1.0.0",
                       description: "RaceTrack - An application to run race simulations for Circle Drivers.")
    }
    
    public func startCLI() {
        cli.commands = [RunSimulationCommand(), RerunSimulationCommand()]
        cli.globalOptions.append(globalAnimationStepTimeKey)
        cli.globalOptions.append(globalMaxIterationsKey)
        cli.globalOptions.append(verboseFlag)
        cli.goAndExit()
    }
}

extension Command {
    var verbose: Bool {
        return verboseFlag.value
    }
    
    var globalAnimationStepTime: Double? {
        return globalAnimationStepTimeKey.value
    }
    
    var globalMaxIterations: Int? {
        return globalMaxIterationsKey.value
    }
    
    func verbosePrint(_ string: String) {
        if verbose { Swift.print(string) }
    }
}
