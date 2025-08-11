import SwiftUI
import Charts

enum BatteryRange: String, CaseIterable, Identifiable {
    case day = "24 giờ qua"
    case tenDays = "10 ngày qua"
    var id: String { rawValue }
}

struct BatterySummaryCard: View {
    @StateObject private var vm = BatteryViewModel()
    @State private var selection: BatteryRange = .day

    private func prettyMinutes(_ m: Int) -> String {
        let h = m / 60, min = m % 60
        if h == 0 { return "\(min) phút" }
        if min == 0 { return "\(h) giờ" }
        return "\(h) giờ, \(min) phút"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            

            Picker("", selection: $selection) {
                ForEach(BatteryRange.allCases) { r in Text(r.rawValue).tag(r) }
            }
            .pickerStyle(.segmented)
            
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Lần gần nhất được sạc đến \(vm.lastChargePercent)%")
                    .font(.headline)
                Text("Quá trình sạc đã dừng do nhiệt độ của iPhone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            Group {
                if selection == .day {
                    Text("MỨC PIN").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 16)
                    BatteryLevelChart24h(data: vm.points24h)
                        .frame(height: 180)
                        .padding(.horizontal, 16)

                    Text("HOẠT ĐỘNG").font(.caption).foregroundStyle(.secondary)
                        .padding(.horizontal, 16).padding(.top, 2)
                    ActivityChart24h(data: vm.activity24h)
                        .frame(height: 160)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)

                    // Tổng hợp
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Màn hình hoạt động").font(.caption).foregroundStyle(.secondary)
                            Text(prettyMinutes(vm.activity24h.reduce(0) { $0 + $1.activeMinutes }))
                        }
                        Spacer(minLength: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Màn hình nghỉ").font(.caption).foregroundStyle(.secondary)
                            Text(prettyMinutes(vm.activity24h.reduce(0) { $0 + $1.idleMinutes }))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 2)
                } else {
                    Text("SỬ DỤNG PIN").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 16)
                    BatteryChart10Days(data: vm.days10)
                        .frame(height: 180)
                        .padding(.horizontal, 16)

                    Text("HOẠT ĐỘNG").font(.caption).foregroundStyle(.secondary)
                        .padding(.horizontal, 16).padding(.top, 2)
                    ActivityChart10Days(data: vm.activity10)
                        .frame(height: 160)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)

                    // Trung bình 10 ngày
                    let avgOn  = vm.activity10.isEmpty ? 0 : vm.activity10.map { $0.screenOnMinutes }.reduce(0,+) / vm.activity10.count
                    let avgOff = vm.activity10.isEmpty ? 0 : vm.activity10.map { $0.screenOffMinutes }.reduce(0,+) / vm.activity10.count
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Màn hình hoạt động TB").font(.caption).foregroundStyle(.secondary)
                            Text(prettyMinutes(avgOn))
                        }
                        Spacer(minLength: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Màn hình nghỉ TB").font(.caption).foregroundStyle(.secondary)
                            Text(prettyMinutes(avgOff))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 2)
                }
            }
        }
        .padding(.vertical, 10)
        .background {
            // iOS Settings card look
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 0.5).opacity(0.25)
        }
        .padding(.horizontal, 16)
    }
}
