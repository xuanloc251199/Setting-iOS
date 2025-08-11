//
//  BatteryChart10Days.swift
//  Preferences
//
//  10-day battery charts (Usage % and Activity)
//

import SwiftUI
import Charts

// MARK: - Battery usage (10 ngày)
struct BatteryChart10Days: View {
    let data: [DailyBattery]

    var body: some View {
        Chart(data) { d in
            BarMark(
                x: .value("Day", d.day),
                y: .value("Usage", d.usagePercent)
            )
            .cornerRadius(3)
            .foregroundStyle(Color.green)
        }
        // Giữ đúng thứ tự ngày như mảng truyền vào
        .chartXScale(domain: data.map { $0.day })
        // iOS Battery hiển thị tới 200%
        .chartYScale(domain: 0...200)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 100, 200]) { v in
                AxisGridLine().foregroundStyle(.quaternary)
                if let val = v.as(Int.self) {
                    AxisValueLabel { Text("\(val)%") }.font(.footnote)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: data.map { $0.day }) { _ in
                AxisValueLabel().font(.footnote)
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { $0.background(.clear) }
    }
}

// MARK: - Activity (10 ngày)
// 2 cột xanh CHỒNG (stack) theo ngày: "Screen On" đậm + "Screen Off" nhạt
struct ActivityChart10Days: View {
    let data: [DailyActivity]

    var body: some View {
        Chart {
            ForEach(data) { d in
                // Màn hình bật (đậm)
                BarMark(
                    x: .value("Day", d.day),
                    y: .value("Minutes", d.screenOnMinutes)
                )
                .foregroundStyle(Color.blue)
                .cornerRadius(3)
                .position(by: .value("Kind", "On"))

                // Màn hình nghỉ (nhạt) – stack lên trên
                BarMark(
                    x: .value("Day", d.day),
                    y: .value("Minutes", d.screenOffMinutes)
                )
                .foregroundStyle(Color.blue.opacity(0.35))
                .cornerRadius(3)
                .position(by: .value("Kind", "Off"))
            }
        }
        .chartXScale(domain: data.map { $0.day })
        // 0 → 12 giờ (720 phút)
        .chartYScale(domain: 0...720)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 180, 360, 540, 720]) { v in
                AxisGridLine().foregroundStyle(.quaternary)
                if let val = v.as(Int.self) {
                    AxisValueLabel {
                        if val == 0 { Text("0ph") } else { Text("\(val/60)g") }
                    }
                    .font(.footnote)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: data.map { $0.day }) { _ in
                AxisValueLabel().font(.footnote)
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { $0.background(.clear) }
    }
}

#if DEBUG
// MARK: - Preview (dùng dữ liệu giả)
struct BatteryChart10Days_Previews: PreviewProvider {
    static let mockBattery: [DailyBattery] = {
        let days = ["T5","T6","T7","CN","T2","T3","T4","T5","T6","T7"]
        let vals = [120,100,130,90,85,95,160,140,150,90]
        return zip(days, vals).map { .init(day: $0.0, usagePercent: $0.1) }
    }()

    static let mockActivity: [DailyActivity] = {
        let days = ["T5","T6","T7","CN","T2","T3","T4","T5","T6","T7"]
        let on  =  [360, 330, 350, 280, 260, 300, 450, 420, 440, 270] // phút
        let off = [30,   25,  28,  18,  22,  26,  35,  33,  36,  20]
        return (0..<days.count).map { .init(day: days[$0], screenOnMinutes: on[$0], screenOffMinutes: off[$0]) }
    }()

    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            BatteryChart10Days(data: mockBattery)
                .frame(height: 180)
            ActivityChart10Days(data: mockActivity)
                .frame(height: 160)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
#endif
