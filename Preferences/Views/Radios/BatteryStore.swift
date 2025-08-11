import Foundation

final class BatteryStore {
    static let shared = BatteryStore()
    private init() {}

    private let queue = DispatchQueue(label: "BatteryStoreQueue")

    private lazy var fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("battery_log.json")
    }()

    func load() -> [BatterySample] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([BatterySample].self, from: data)) ?? []
    }

    func append(_ sample: BatterySample) {
        queue.async {
            var items = self.load()
            items.append(sample)
            if let cutoff = Calendar.current.date(byAdding: .day, value: -10, to: Date()) {
                items = items.filter { $0.date >= cutoff }
            }
            if let data = try? JSONEncoder().encode(items) {
                try? data.write(to: self.fileURL, options: .atomic)
            }
        }
    }
}
