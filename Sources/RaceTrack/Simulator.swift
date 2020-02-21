import CircleDriver

public class Simulator {
    public func startSimulation(with drivers: [CircleDriverProtocol], on raceTrack: RaceTrack) -> SimulationLog {
        let log = SimulationLog(raceTrack: raceTrack)
        var iteration = 0
        let driversTracking = drivers.enumerated().map { DriverTracking(driver: $0.element, circle: raceTrack.circle, color: Color.driverColors[$0.offset % Color.driverColors.count]) }
        let obstaclesTracking = raceTrack.obstacles.map { ObstacleTracking(obstacle: $0) }
        let logCurrentState: () -> Void = {
            log.log(drivers: driversTracking,
                    obstacles: obstaclesTracking,
                    destination: raceTrack.destination.circle(with: raceTrack.circle.radius))
        }
        // Logging initial state
        logCurrentState()

        repeat {
            defer {
                // Loggin current state at the end of each loop
                logCurrentState()
            }
            // Move drivers
            driversTracking.filter({ $0.stillMoving }).forEach {
                let movement = $0.driver.movement(for: $0.circle,
                                                  goingTo: raceTrack.destination,
                                                  withMaximumStep: raceTrack.maximumStep,
                                                  avoidingCollisionsWith: raceTrack.obstacles)
                guard movement.step <= raceTrack.maximumStep else {
                    $0.mark(as: .fault(iteration))
                    return
                }
                $0.apply(movement: movement)
            }
            // Move obstacles
            obstaclesTracking.forEach {
                $0.move()
            }
            // Check collisions
            driversTracking.filter({ $0.stillMoving }).forEach { driver in
                obstaclesTracking.map({ $0.obstacle.circle }).forEach { obstacle in
                    if driver.circle.position.distance(to: obstacle.position) < (driver.circle.radius + obstacle.radius) {
                        driver.mark(as: .collision(iteration))
                    }
                }
            }
            // Check finished
            driversTracking
                .filter({ $0.stillMoving && $0.hasReached(point: raceTrack.destination) })
                .forEach({ $0.mark(as: .finished(iteration)) })
            iteration += 1
        } while iteration < raceTrack.maximumIterations && !driversTracking.filter({ $0.stillMoving }).isEmpty
        
        // Check timeout
        driversTracking.filter({ $0.stillMoving }).forEach { $0.mark(as: .timeout(iteration)) }
        
        return log
    }
}
