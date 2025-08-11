import SwiftUI
import Charts

// MARK: - Helpers
private func hourTicks24h(from data: [Date]) -> [Date] {
    guard let last = data.last else { return [] }
    let cal = Calendar.current
    let base = cal.dateInterval(of: .hour, for: last)?.start
        ?? cal.date(bySettingHour: cal.component(.hour, from: last),
                    minute: 0, second: 0, of: last)!
    // mốc 18, 21, 00 giờ, 06, 09, 12 giờ (giống ảnh)
    let hours: [Int] = [-18, -15, -12, -6, -3, 0]
    return hours.compactMap { cal.date(byAdding: .hour, value: $0, to: base) }
}

// MARK: - 24h Battery Level
struct BatteryLevelChart24h: View {
    let data: [BatteryPoint]

    var body: some View {
        Chart {
            // nền highlight khoảng đang sạc
            if let first = data.first(where: { $0.isCharging }),
               let last  = data.last(where:  { $0.isCharging }) {
                RectangleMark(
                    xStart: .value("Start", first.date),
                    xEnd:   .value("End",   last.date),
                    yStart: .value("y0", 0),
                    yEnd:   .value("y1", 100)
                )
                .foregroundStyle(.green.opacity(0.14))
            }

            ForEach(data) { p in
                BarMark(
                    x: .value("Time", p.date),
                    y: .value("Level", p.level)
                )
                .cornerRadius(2)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.95),
                                                Color.green.opacity(0.75)]),
                    startPoint: .top, endPoint: .bottom)
                )
            }

            // icon sét tại lúc bắt đầu sạc
            if let bolt = data.first(where: { $0.isCharging }) {
                PointMark(x: .value("bolt", bolt.date), y: .value("zero", 0))
                    .symbol {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100]) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                if let v = value.as(Int.self) {
                    AxisValueLabel { Text("\(v)%") }.font(.footnote)
                }
            }
        }
        .chartXAxis {
            let xs = hourTicks24h(from: data.map { $0.date })
            AxisMarks(values: xs) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        let h = Calendar.current.component(.hour, from: d)
                        if h == 0 || h == 12 {
                            Text(String(format: "%02d giờ", h))
                        } else {
                            Text(String(format: "%02d", h))
                        }
                    }
                }.font(.footnote)
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { $0.background(.clear) }
    }
}

// MARK: - 24h Activity
struct ActivityChart24h: View {
    let data: [ActivityPoint]

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Time", item.date),
                    y: .value("Active", item.activeMinutes)
                )
                .foregroundStyle(Color.blue)
                .cornerRadius(2)

                if item.idleMinutes > 0 {
                    BarMark(
                        x: .value("Time", item.date),
                        y: .value("Idle", item.idleMinutes)
                    )
                    .foregroundStyle(Color.blue.opacity(0.35))
                    .cornerRadius(2)
                }
            }
        }
        .chartYScale(domain: 0...60)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 30, 60]) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                if let v = value.as(Int.self) {
                    AxisValueLabel { Text("\(v)ph") }.font(.footnote)
                }
            }
        }
        .chartXAxis {
            let xs = hourTicks24h(from: data.map { $0.date })
            AxisMarks(values: xs) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                AxisValueLabel {
                    if let d = value.as(Date.self) {
                        let h = Calendar.current.component(.hour, from: d)
                        if h == 0 || h == 12 {
                            Text(String(format: "%02d giờ", h))
                        } else {
                            Text(String(format: "%02d", h))
                        }
                    }
                }.font(.footnote)
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { $0.background(.clear) }
    }
}
