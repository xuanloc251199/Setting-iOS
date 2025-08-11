//
//  BatteryView.swift
//  Preferences
//
//  Settings > Battery
//

import SwiftUI

struct BatteryView: View {
    // Variables gốc của bạn
    @AppStorage("batteryPercentage") private var batteryPercentageEnabled = true
    @AppStorage("lowPowerMode") private var lowPowerModeEnabled = false
    let table = "BatteryUI"

    // State cho card (không dùng data)
    private enum BatteryRange: String, CaseIterable, Identifiable {
        case day = "24 giờ qua"
        case tenDays = "10 ngày qua"
        var id: String { rawValue }
    }
    @State private var selection: BatteryRange = .day

    init() {
        lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var body: some View {
        CustomList(title: "BATTERY_TITLE".localize(table: table)) {
            Section {
                Toggle("BATTERY_PERCENTAGE".localize(table: table), isOn: $batteryPercentageEnabled)
                Toggle("BATTERY_SAVER_MODE".localize(table: table), isOn: $lowPowerModeEnabled)
            } footer: {
                Text(UIDevice.iPhone ? "FOOTNOTE_BATTERYSAVERMODE_IPHONE" : "FOOTNOTE_BATTERYSAVERMODE_IPAD", tableName: table)
            }

            Section {
                SettingsLink("Tình trạng pin & sạc".localize(table: table),
                             destination: BatteryHealthChargingView())
            }

//            Section {
//                Text(UIDevice.iPhone ? "NOTENOUGHINFO_IPHONE" : "NOTENOUGHINFO_IPAD", tableName: "BatteryUI")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity)
//                    .multilineTextAlignment(.center)
//            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {

                    // Segmented control
                    Picker("", selection: $selection) {
                        ForEach(BatteryRange.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    // Headline
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lần gần nhất được sạc đến 30%")
                            .font(.headline)
                        Text("Quá trình sạc đã dừng do nhiệt độ của iPhone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    Image(selection == .day ? "1" : "2")
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel(selection == .day ? "Biểu đồ 24 giờ qua" : "Biểu đồ 10 ngày qua")
                        
                        .padding(.bottom, 8)
                }
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 0.5).opacity(0.25)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }
        }
    }
}

#Preview {
    NavigationStack { BatteryView() }
}
