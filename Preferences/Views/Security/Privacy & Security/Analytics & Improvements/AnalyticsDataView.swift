//
//  AnalyticsDataView.swift
//  Preferences
//
//  Settings > Privacy & Security > Analytics & Improvements > Analytics Data
//

import SwiftUI

struct AnalyticsDataView: View {
    // Variables
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var items: [AnalyticsItem] = []
    
    private var filtered: [AnalyticsItem] {
        guard !searchText.isEmpty else { return items }
        let q = searchText.lowercased()
        return items.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        CustomList(title: "Data", topPadding: true) {
            if isLoading {
                HStack { ProgressView() }
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Section {
                    ForEach(filtered) { item in
                        NavigationLink {
                            AnalyticsDataDetailView(item: item)
                        } label: {
                            Text(item.name)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: Text("Tìm kiếm"))
        .task {
            await loadMockFiles()
        }
    }

    // MARK: - Data loading (mock để dựng UI giống ảnh)
    private func loadMockFiles() async {
        try? await Task.sleep(nanoseconds: 300_000_000)

        var generated: [AnalyticsItem] = []
        let now = Date()
        let cal = Calendar.current
        
        func stamp(offsetMinutes: Int) -> String {
            let d = cal.date(byAdding: .minute, value: -offsetMinutes, to: now) ?? now
            let f = DateFormatter()
            f.locale = .init(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd-HHmmss"
            return f.string(from: d)
        }

        func add(_ name: String) {
            generated.append(AnalyticsItem(name: name))
        }

        // Analytics (ips.ca…)
        for i in [43803, 70004, 70004 + 86400] { // vài mốc thời gian
            add("Analytics-\(stamp(offsetMinutes: i)).ips.ca.synced")
        }

        // Resource / diskwrites…
        add("cfprefsd.diskwrites_resource-\(stamp(offsetMinutes: 1200)).ips")
        add("com.apple.StreamingUnzipService.diskwrites_resource-\(stamp(offsetMinutes: 1180)).ips")
        add("PerfPowerServices.diskwrites_resource-\(stamp(offsetMinutes: 990)).ips")
        add("SpringBoard.diskwrites_resource-\(stamp(offsetMinutes: 720)).ips")

        // Jetsam
        for mins in [4049, 185815, 210433] {
            add("JetsamEvent-\(stamp(offsetMinutes: mins)).ips")
        }

        // WiFi logs
        for mins in [205000, 212011, 213011] {
            add("WiFiLQMMetrics-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [202000, 203000, 204000] {
            add("WiFiConnectionQuality-\(stamp(offsetMinutes: mins)).ips")
        }

        // SFA (CloudServices / ckks / transparency / sos / pcs / networking / local)
        for mins in [125115, 185331] {
            add("SFA-ckks.json-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [125110, 185330] {
            add("SFA-CloudServices.json-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [125116, 185333] {
            add("SFA-local.json-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [125117, 185334] {
            add("SFA-networking.json-\(stamp(offsetMinutes: mins)).ips")
        }
        add("SFA-pcs.json-\(stamp(offsetMinutes: 125115)).00001.ips")
        for mins in [125115, 185332] {
            add("SFA-sos.json-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [125118, 185335] {
            add("SFA-transparency.json-\(stamp(offsetMinutes: mins)).ips")
        }
        for mins in [125119, 185336] {
            add("SFA-swtransparency.json-\(stamp(offsetMinutes: mins)).ips")
        }

        // SiriSearchFeedback (rất nhiều mục)
        for mins in stride(from: 43000, through: 131000, by: 1500) {
            add("SiriSearchFeedback-\(stamp(offsetMinutes: mins)).ips")
        }

        // knowledgeconstructiond, logd
        add("knowledgeconstructiond.cpu_resource-\(stamp(offsetMinutes: 850)).ips")
        add("logd.diskwrites_resource-\(stamp(offsetMinutes: 840)).ips")

        // LowBatteryLog
        add("LowBatteryLog-\(stamp(offsetMinutes: 232802)).ips")

        // App usage
        add("xp_amp_app_usage_dnu-\(stamp(offsetMinutes: 125000)).ips")
        add("xp_amp_app_usage_dnu-\(stamp(offsetMinutes: 185000)).ips")

        // Sắp xếp theo alphabet (iOS hiển thị như vậy)
        generated.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        items = generated
        isLoading = false
    }
}

// MARK: - Models & Detail placeholder
private struct AnalyticsItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

private struct AnalyticsDataDetailView: View {
    let item: AnalyticsItem
    var body: some View {
        Text(item.name)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding()
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AnalyticsDataView()
    }
}
