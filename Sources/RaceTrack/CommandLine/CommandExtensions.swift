import CircleDriver
import SwiftCLI
import Foundation

extension Area: ConvertibleFromString {
    public init?(input: String) {
        let components = input.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: ",")
        guard components.count == 4 else { return nil }
        let xString = components[0].trimmingCharacters(in: CharacterSet.whitespaces)
        let yString = components[1].trimmingCharacters(in: CharacterSet.whitespaces)
        let widthString = components[2].trimmingCharacters(in: CharacterSet.whitespaces)
        let heightString = components[3].trimmingCharacters(in: CharacterSet.whitespaces)
        guard let x = Double(input: xString),
              let y = Double(input: yString),
              let width = Double(input: widthString), width >= 0.0,
              let height = Double(input: heightString), height >= 0.0 else { return nil }
        self.init(x: x, y: y, width: width, height: height)
    }
}

extension ClosedRange: ConvertibleFromString where Bound == Radius {
    public init?(input: String) {
        let components = input.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: "...")
        guard components.count == 2 else { return nil }
        let lowerString = components[0].trimmingCharacters(in: CharacterSet.whitespaces)
        let upperString = components[1].trimmingCharacters(in: CharacterSet.whitespaces)
        guard let lower = Double(input: lowerString),
              let upper = Double(input: upperString) else { return nil }
        self.init(uncheckedBounds: (lower, upper))
    }
}
