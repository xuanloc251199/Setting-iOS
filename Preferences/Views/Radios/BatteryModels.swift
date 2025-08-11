import Foundation

// 24h
struct BatteryPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let level: Int        // 0...100
    let isCharging: Bool
}

struct ActivityPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let activeMinutes: Int    // 0...60
    let idleMinutes: Int      // 0...60
}

// 10 ngày
struct DailyBattery: Identifiable, Hashable {
    let id = UUID()
    let day: String           // "T2","T3",...
    let usagePercent: Int     // 0...150
}

struct DailyActivity: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let screenOnMinutes: Int  // phút
    let screenOffMinutes: Int // phút
}
