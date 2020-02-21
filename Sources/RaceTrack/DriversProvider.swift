import CircleDriver
import JustGoTowardsCircleDriver

class DriversProvider {
    // Add your drivers here
    static let `default`: DriversProvider = DriversProvider(drivers: [
        JustGoTowardsCircleDriver(stepPercentage: 1.0),
        JustGoTowardsCircleDriver(stepPercentage: 0.5),
    ])
    
    let drivers: [CircleDriverProtocol]
    
    init(drivers: [CircleDriverProtocol]) {
        self.drivers = drivers
    }
}
