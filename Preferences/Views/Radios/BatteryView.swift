//
//  BatteryView.swift
//  Preferences
//
//  Settings > Battery
//

import SwiftUI

struct BatteryView: View {
    // Gốc
    @AppStorage("batteryPercentage") private var batteryPercentageEnabled = true
    @AppStorage("lowPowerMode") private var lowPowerModeEnabled = false
    let table = "BatteryUI"

    // 24h / 10 ngày
    private enum BatteryRange: String, CaseIterable, Identifiable {
        case day = "24 giờ qua"
        case tenDays = "10 ngày qua"
        var id: String { rawValue }
    }
    @State private var selection: BatteryRange = .day

    // 1 section – 2 trạng thái tiêu đề
    private enum BreakdownMode { case usageByApp, activityByApp }
    @State private var breakdownMode: BreakdownMode = .usageByApp

    init() {
        lowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var body: some View {
        CustomList(title: "BATTERY_TITLE".localize(table: table)) {
            
            // Toggles
            Section {
                Toggle("BATTERY_PERCENTAGE".localize(table: table), isOn: $batteryPercentageEnabled)
                Toggle("BATTERY_SAVER_MODE".localize(table: table), isOn: $lowPowerModeEnabled)
            } footer: {
                Text(UIDevice.iPhone ? "FOOTNOTE_BATTERYSAVERMODE_IPHONE" : "FOOTNOTE_BATTERYSAVERMODE_IPAD", tableName: table)
            }
            
            // Pin & Sạc
            Section {
                SettingsLink("Tình trạng pin & sạc".localize(table: table),
                             destination: BatteryHealthChargingView())
            }
            
            // ===== TẤT CẢ NẰM CHUNG 1 SECTION =====
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Segmented: 24 giờ qua / 10 ngày qua
                    Picker("", selection: $selection) {
                        ForEach(BatteryRange.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    
                    // Headline
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lần gần nhất được sạc đến 47%")
                            .font(.headline)
                        Text("Quá trình sạc đã dừng do nhiệt độ của iPhone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    
                    // Biểu đồ trên (24h/10 ngày) – đổi *không* animation
                    Image(topChartImageName)
                        .resizable()
                        .scaledToFit()
                        .accessibilityHidden(true)
                        .animation(nil, value: selection)
                    
                    // Hàng đổi tiêu đề (1 section – 2 trạng thái)
                    HStack {
                        Text(leftTitle)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        Spacer(minLength: 8)
                        
                        Button(rightTitle) {
                            // Đổi trạng thái *không* animation
                            toggleBreakdownMode()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 16)
                    
                    // Ảnh breakdown — đổi *không* animation
                    Image(breakdownImageName)
                        .resizable()
                        .scaledToFit()
                        .accessibilityHidden(true)
                        .padding(.top, 2)
                        .animation(nil, value: breakdownMode)   // <- quan trọng
                        .animation(nil, value: selection)       // <- quan trọng
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
            } footer: {
                Text("Hiển thị tỷ lệ pin mà mỗi ứng dụng đã sử dụng")
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Helpers (tiêu đề)
    private var leftTitle: String {
        switch breakdownMode {
        case .usageByApp:    return "SỬ DỤNG PIN THEO ƯD"
        case .activityByApp: return "HOẠT ĐỘNG THEO ƯD"
        }
    }
    private var rightTitle: String {
        switch breakdownMode {
        case .usageByApp:    return "HIỂN THỊ HOẠT ĐỘNG"
        case .activityByApp: return "MỨC SỬ DỤNG PIN"
        }
    }
    private func toggleBreakdownMode() {
        breakdownMode = (breakdownMode == .usageByApp) ? .activityByApp : .usageByApp
    }

    // MARK: - Helpers (ảnh)
    /// Ảnh chart trên cùng (mức pin/hoạt động): khác giữa 24h & 10 ngày
    private var topChartImageName: String {
        switch selection {
        case .day:     return "battery_24h"   // ảnh 24h (như bạn đã add)
        case .tenDays: return "battery_10day"   // ảnh 10 ngày (đặt asset này)
        }
    }

    /// Ảnh breakdown dưới: phụ thuộc cả `selection` lẫn `breakdownMode`
    private var breakdownImageName: String {
        switch (selection, breakdownMode) {
        case (.day, .usageByApp):     return "battery_breakdown_usage_24h"
        case (.day, .activityByApp):  return "battery_breakdown_activity_24h"
        case (.tenDays, .usageByApp): return "battery_breakdown_usage_10d"
        case (.tenDays, .activityByApp): return "battery_breakdown_activity_10d"
        }
    }
}

#Preview {
    NavigationStack { BatteryView() }
}
