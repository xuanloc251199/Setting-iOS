import Foundation

final class BatteryViewModel: ObservableObject {
    @Published var points24h: [BatteryPoint] = []
    @Published var activity24h: [ActivityPoint] = []
    @Published var days10: [DailyBattery] = []
    @Published var activity10: [DailyActivity] = []
    @Published var lastChargePercent: Int = 0
    @Published var showBrightnessTip: Bool = true // bật sẵn banner cho giống ảnh

    init() {
        loadMock()
    }

    func loadMock() {
        points24h   = BatteryDataGenerator.make24h()
        activity24h = BatteryDataGenerator.make24hActivity()
        days10      = BatteryDataGenerator.make10Days()
        activity10  = BatteryDataGenerator.make10DaysActivity()
        lastChargePercent = points24h.map { $0.level }.max() ?? 0
    }
}
