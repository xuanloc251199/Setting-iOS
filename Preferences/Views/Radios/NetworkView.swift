//
//  NetworkView.swift
//  Preferences
//
//  Settings > Wi-Fi
//

import SwiftUI

struct NetworkView: View {
    @AppStorage("wifi") private var wifiEnabled = true
    @AppStorage("WiFiDisplayName") private var wifiDisplayName = "Not Connected" // hiện ra ở ContentView
    @AppStorage("SavedWiFiName") private var savedWiFiName = "My Wi-Fi"          // NHỚ tên mạng của tôi
    @AppStorage("AskJoinNetworkSelection") private var askJoinNetworkSelection = "kWFLocAskToJoinDetailNotify"
    @AppStorage("AutoJoinHotspotSelection") private var autoJoinHotspotSelection = "kWFLocAutoInstantHotspotJoinAskTitle"

    @State var editMode: EditMode = .inactive
    @State var isEditing = false
    @State private var connected = false
    @State private var frameY = 0.0
    @State private var opacity = 0.0
    @State private var searching = true
    @State private var showingHelpSheet = false
    @State private var showingOtherNetwork = false
    @State private var timer: Timer? = nil
    @State private var currentTopicID = ""

    // Dữ liệu danh sách
    @State private var myNetwork: WiFiNetwork? = nil               // mạng đã/sẽ kết nối
    @State private var otherNetworks: [WiFiNetwork] = []           // các mạng lân cận

    // Đổi tên hiển thị Wi-Fi
    @State private var showRenameSheet = false
    @State private var renameText = ""
    @FocusState private var renameFieldFocused: Bool

    let table = "WiFiKitUILocalizableStrings"

    var body: some View {
        CustomList(title: "kWFLocWiFiPowerTitle".localize(table: table), topPadding: true) {
            if isEditing {
                Section {} header: {
                    Text("kWFLocAllEditableKnownSectionTitle", tableName: table)
                }
            } else {
                // --- Placard + Toggle ---
                Section {
                    Placard(
                        title: "kWFLocWiFiPlacardTitle".localize(table: table),
                        color: Color.blue,
                        icon: "wifi",
                        description: NSLocalizedString("kWFLocWiFiPlacardSubtitle", tableName: table, comment: "").replacing("helpkit", with: "pref"),
                        frameY: $frameY,
                        opacity: $opacity
                    )

                    Toggle(isOn: $wifiEnabled) {
                        HStack {
                            Image(systemName: "checkmark").foregroundStyle(.clear)
                            Text("kWFLocWiFiPowerTitle", tableName: table)
                        }
                    }
                    .onChange(of: wifiEnabled, initial: false) { _, isOn in
                        if isOn {
                            // Bật lại: phục hồi “Mạng của tôi” từ SavedWiFiName nếu chưa kết nối
                            if !connected {
                                myNetwork = WiFiNetwork(
                                    ssid: savedWiFiName,
                                    secured: true,
                                    strength: 2
                                )
                            }
                            startScan()
                        } else {
                            // Tắt Wi-Fi => tắt mọi kết nối hiện tại, nhưng KHÔNG xóa saved
                            connected = false
                            wifiDisplayName = "Not Connected"
                            // Giữ myNetwork = saved (để khi bật lại vẫn hiện “Mạng của tôi”)
                            if myNetwork == nil {
                                myNetwork = WiFiNetwork(ssid: savedWiFiName, secured: true, strength: 2)
                            }
                            otherNetworks.removeAll()
                            stopScan()
                        }
                    }

                    // Mạng hiện tại (tap để đổi tên hiển thị)
                    if connected, let current = myNetwork {
                        ZStack {
                            WiFiRow(network: current, isConnected: true, wifiEnabled: wifiEnabled)
                                .allowsHitTesting(false)

                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard wifiEnabled else { return }
                                    renameText = wifiDisplayName == "Not Connected" ? current.ssid : wifiDisplayName
                                    showRenameSheet = true
                                }
                        }
                    }
                } footer: {
                    if !wifiEnabled {
                        Text(UIDevice.iPhone ? "kWFLocLocationServicesCellularWarning" : "kWFLocLocationServicesWarning", tableName: table)
                    }
                }

                // --- Mạng của tôi (Saved / Known) ---
                if wifiEnabled, let saved = myNetwork, !connected {
                    Section {
                        Button {
                            connectMyNetwork(saved)
                        } label: {
                            WiFiRow(network: saved, isConnected: false, wifiEnabled: wifiEnabled)
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("Mạng của tôi")
                    }
                }

                // --- Danh sách mạng xung quanh ---
                if wifiEnabled {
                    Section {
                        ForEach(otherNetworks) { net in
                            WiFiRow(network: net, isConnected: false, wifiEnabled: wifiEnabled)
                        }

                        // Other…
                        Button {
                            showingOtherNetwork.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark").foregroundStyle(.clear)
                                Text("kWFLocOtherNetworkTitle", tableName: table)
                            }
                        }
                        .foregroundStyle(.primary)

                    } header: {
                        HStack {
                            Text("kWFLocChooseNetworkSectionSingleTitle", tableName: table)
                            if searching {
                                ProgressView()
                                    .frame(height: 0)
                            }
                        }
                    }
                    .onAppear { startScan() }
                    .onDisappear { stopScan() }

                    // Ask to Join
                    Section {
                        SettingsLink(
                            "kWFLocAskToJoinTitle".localize(table: table),
                            status: askJoinNetworkSelection.localize(table: table),
                            destination: SelectOptionList(
                                "kWFLocAskToJoinTitle",
                                options: ["kWFLocAskToJoinDetailOff", "kWFLocAskToJoinDetailNotify", "kWFLocAskToJoinDetailAsk"],
                                selectedBinding: $askJoinNetworkSelection,
                                table: table
                            )
                        )
                    } footer: {
                        Text("kWFLocAskToJoinNotifyFooter", tableName: table)
                    }

                    // Auto-Join Hotspot
                    Section {
                        SettingsLink(
                            "kWFLocAutoInstantHotspotTitle".localize(table: table),
                            status: autoJoinHotspotSelection.localize(table: table),
                            destination: SelectOptionList(
                                "kWFLocAutoInstantHotspotTitle",
                                options: ["kWFLocAutoInstantHotspotJoinNeverTitle", "kWFLocAutoInstantHotspotJoinAskTitle", "kWFLocAutoInstantHotspotJoinAutoTitle"],
                                selectedBinding: $autoJoinHotspotSelection,
                                table: table
                            )
                        )
                    } footer: {
                        Text("kWFLocAutoInstantHotspotFooter", tableName: table)
                    }
                }
            }
        }
        .onOpenURL { _ in
            showingHelpSheet.toggle()
        }
        .sheet(isPresented: $showingHelpSheet) {
            HelpKitView(topicID: UIDevice.iPhone ? "iphd1cf4268" : "ipad2db29c3a")
                .ignoresSafeArea(edges: .bottom)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingOtherNetwork) {
            OtherNetworkView()
        }
        // Sheet đổi tên hiển thị cho Wi-Fi đang kết nối
        .sheet(isPresented: $showRenameSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Tên hiển thị Wi-Fi")) {
                        TextField("Nhập tên hiển thị", text: $renameText)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .focused($renameFieldFocused)
                            .submitLabel(.done)
                            .onSubmit { applyRename() }
                    }
                    Text("Tên này chỉ thay đổi cách hiển thị trong Cài đặt.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Đổi tên Wi-Fi")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Hủy") { showRenameSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Xong") { applyRename() }
                            .disabled(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .onAppear { DispatchQueue.main.async { renameFieldFocused = true } }
            }
            .presentationDetents([.height(200), .medium])
            .interactiveDismissDisabled(false)
        }
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("kWFLocAdhocJoinCancelButton".localize(table: table)) {
                        withAnimation { isEditing.toggle() }
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("kWFLocWiFiPlacardTitle", tableName: table)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .opacity(frameY < 50.0 ? opacity : 0)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "kWFLocEditListButtonTitle".localize(table: table)) {
                    withAnimation { isEditing.toggle() }
                }
                .fontWeight(isEditing ? .bold : .regular)
                .disabled(isEditing)
            }
        }
        .onAppear {
            // Nếu đang kết nối -> từ wifiDisplayName
            connected = wifiEnabled && !wifiDisplayName.isEmpty && wifiDisplayName != "Not Connected"
            if connected {
                myNetwork = WiFiNetwork(ssid: wifiDisplayName, secured: true, strength: 3)
                // Lưu lại tên vào SavedWiFiName để sau này bật lại vẫn còn “Mạng của tôi”
                savedWiFiName = wifiDisplayName
            } else {
                // Không kết nối => hiển thị “Mạng của tôi” từ saved
                myNetwork = WiFiNetwork(ssid: savedWiFiName, secured: true, strength: 2)
            }
        }
    }

    // MARK: - Actions
    private func connectMyNetwork(_ net: WiFiNetwork) {
        guard wifiEnabled else { return }
        connected = true
        wifiDisplayName = net.ssid
        savedWiFiName = net.ssid // cập nhật saved
        myNetwork = WiFiNetwork(ssid: net.ssid, secured: net.secured, strength: 3)
    }

    private func applyRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        wifiDisplayName = trimmed
        savedWiFiName = trimmed // đồng bộ saved để khi bật lại vẫn hiện “Mạng của tôi”
        connected = true
        if let current = myNetwork {
            myNetwork = WiFiNetwork(ssid: trimmed, secured: current.secured, strength: current.strength)
        } else {
            myNetwork = WiFiNetwork(ssid: trimmed, secured: true, strength: 3)
        }
        showRenameSheet = false
    }

    // MARK: - Scan Simulation
    private func startScan() {
        stopScan()
        searching = true
        generateNetworks()
        // Vòng quét lặp để spinner xuất hiện định kỳ
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            Task { await beignConstantScan() }
        }
        Task { await beignConstantScan() }
    }

    private func stopScan() {
        searching = false
        timer?.invalidate()
        timer = nil
    }

    @MainActor
    private func beignConstantScan() async {
        searching = true
        try? await Task.sleep(for: .seconds(Int.random(in: 1...2)))
        generateNetworks()
        searching = false
    }

    private func generateNetworks() {
        // Tạo danh sách “mạng khác” giả lập
        let pool: [WiFiNetwork] = [
            .init(ssid: "VNPT_5G",           secured: true,  strength: Int.random(in: 1...3)),
            .init(ssid: "FPT_Home_2.4G",     secured: true,  strength: Int.random(in: 1...3)),
            .init(ssid: "CoffeeHouse",       secured: true,  strength: Int.random(in: 1...3)),
            .init(ssid: "Airport_Free_WiFi", secured: false, strength: Int.random(in: 1...3)),
            .init(ssid: "Company_Guest",     secured: true,  strength: Int.random(in: 1...3)),
            .init(ssid: "Neighbor-AP",       secured: true,  strength: Int.random(in: 1...3))
        ]
        otherNetworks = Array(pool.prefix(5))
    }
}

// MARK: - Models & Rows

private struct WiFiNetwork: Identifiable, Equatable {
    let id = UUID()
    let ssid: String
    let secured: Bool
    /// 1...3 (yếu -> mạnh) — dùng để đổi opacity icon
    let strength: Int
}

private struct WiFiRow: View {
    let network: WiFiNetwork
    var isConnected: Bool
    var wifiEnabled: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark")
                    .foregroundStyle(isConnected ? .blue : .clear)
                    .fontWeight(.semibold)

                Text(network.ssid)
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                if network.secured {
                    Image(systemName: "lock.fill")
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: wifiEnabled ? "wifi" : "wifi.slash")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
                    .opacity(opacityForLevel(network.strength))

                Button {} label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            NavigationLink(destination: NetworkDetailView(name: network.ssid)) { EmptyView() }
                .opacity(0)
        }
        .contentShape(Rectangle())
    }

    private func opacityForLevel(_ level: Int) -> Double {
        switch max(1, min(level, 3)) {
        case 1: return 0.45
        case 2: return 0.75
        default: return 1.0
        }
    }
}

#Preview {
    NavigationStack {
        NetworkView()
    }
}
