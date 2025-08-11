import Foundation

enum BatteryDataGenerator {
    // Mô phỏng 24h mức pin: tụt dần, đoạn sạc từ 09h→12h (match ảnh)
    static func make24h() -> [BatteryPoint] {
        let now = Date()
        let cal = Calendar.current
        // 24 cột: cũ -> mới
        let base = [92, 89, 86, 84, 82, 80, 78, 76, 74, 73, 72, 70, 68, 66, 64, 62, 60, 58, 56, 80, 96, 92, 78, 68]
        return (0..<24).map { i in
            let d = cal.date(byAdding: .hour, value: -(23 - i), to: now)!
            let hour = cal.component(.hour, from: d)
            let charging = (9...12).contains(hour)
            return BatteryPoint(date: d, level: base[i], isCharging: charging)
        }
    }

    static func make24hActivity() -> [ActivityPoint] {
        let now = Date()
        let cal = Calendar.current
        let active = [12, 8, 5, 3, 2, 1, 1, 2, 5, 8, 15, 18, 6, 4, 3, 2, 1, 2, 10, 25, 40, 35, 22, 12]
        return (0..<24).map { i in
            let d = cal.date(byAdding: .hour, value: -(23 - i), to: now)!
            let on = active[i]
            let off = Int(Double(on) * 0.25)
            return ActivityPoint(date: d, activeMinutes: on, idleMinutes: off)
        }
    }

    static func make10Days() -> [DailyBattery] {
        let symbols = ["T4","T5","T6","T7","CN","T2","T3","T4","T5","T6"]
        let vals =    [140, 120, 130, 100,  85,   95,  105, 135,  125,  80]
        return zip(symbols, vals).map { .init(day: $0.0, usagePercent: $0.1) }
    }

    static func make10DaysActivity() -> [DailyActivity] {
        let symbols = ["T4","T5","T6","T7","CN","T2","T3","T4","T5","T6"]
        let on  =     [420,  360,  380,  300,  270,  320,  340,  410,  370,  300]
        let off =     [40,   35,   30,   20,   25,   30,   28,   41,   33,   25]
        return (0..<symbols.count).map { i in
            .init(day: symbols[i], screenOnMinutes: on[i], screenOffMinutes: off[i])
        }
    }
}
