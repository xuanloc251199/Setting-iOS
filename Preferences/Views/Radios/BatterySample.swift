import Foundation

struct BatterySample: Codable, Identifiable {
    let id: UUID
    let date: Date
    let level: Int          // 0...100
    let isCharging: Bool
    let lowPower: Bool
    let brightness: Double  // 0...1

    init(id: UUID = UUID(),
         date: Date,
         level: Int,
         isCharging: Bool,
         lowPower: Bool,
         brightness: Double) {
        self.id = id
        self.date = date
        self.level = level
        self.isCharging = isCharging
        self.lowPower = lowPower
        self.brightness = brightness
    }
}
