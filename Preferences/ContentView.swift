    //
    //  ContentView.swift
    //  Preferences
    //
    //  Settings
    //

    import SwiftUI
    import TipKit

    struct ContentView: View {
        // Variables
        @AppStorage("PasscodeEnabled") private var passcodeEnabled = true

        @AppStorage("SiriEnabled") private var siriEnabled = false
        @AppStorage("FollowUpDismissed") private var followUpDismissed = false
        @AppStorage("AirplaneMode") private var airplaneModeEnabled = false
        @AppStorage("WiFi") private var wifiEnabled = true
        @AppStorage("Bluetooth") private var bluetoothEnabled = true
        @AppStorage("VPNToggle") private var VPNEnabled = true
        @AppStorage("WiFiDisplayName") private var wifiDisplayName = "Not Connected"
        @State private var showWiFiEditor = false
        @FocusState private var wifiFieldFocused: Bool
        @State private var stateManager = StateManager()
        @State private var searchFocused = false
        @State private var searchText = ""
        @State private var showingSignInSheet = false
        @State private var isLandscape = false
        @State private var id = UUID()
        @State private var preloadRect = true

        @State private var showFaceIDPasscodeSheet = false
        @State private var navigateFaceID = false
        @State private var faceIDDestination: AnyView? = nil

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color.primary
                        .opacity(0.3)
                        .ignoresSafeArea()
                    HStack(spacing: 0.25) {
                        NavigationStack(path: $stateManager.path) {
                            // MARK: - iPadOS Settings
                            if UIDevice.iPad {
                                List(selection: $stateManager.selection) {
                                    if !preloadRect {
                                        Section {
                                            Rectangle()
                                                .foregroundStyle(Color.clear)
                                                .listRowBackground(Color.clear)
                                                .frame(height: 25)
                                        }
                                    }

                                    Button {
                                        showingSignInSheet.toggle()
                                    } label: {
                                        AppleAccountSection()
                                    }
                                    .foregroundStyle(.primary)

                                    if siriEnabled && UIDevice.IntelligenceCapability {
                                        // MARK: TipKit Section
                                        Section {
                                            ImageCreationTipView()
                                        }
                                    }

                                    if !followUpDismissed && !UIDevice.IsSimulator {
                                        Section {
                                            Button {
                                                id = UUID() // Reset destination
                                                stateManager.selection = .followUp
                                            } label: {
                                                SLabel("FOLLOWUP_TITLE".localize(table: "FollowUp"), badgeCount: 1)
                                                    .foregroundStyle(Color(UIColor.label))
                                            }
                                        }
                                    }

                                    // MARK: Radio Settings (iPad)
                                    if !UIDevice.IsSimulator {
                                        Section {
                                            IconToggle("Airplane Mode", isOn: $airplaneModeEnabled, color: Color.orange, icon: "airplane")

                                            ForEach(radioSettings) { setting in
                                                if !phoneOnly.contains(setting.id) && requiredCapabilities(capability: setting.capability) {
                                                    if setting.id == "Wi-Fi" {
                                                        Button {
                                                            showWiFiEditor = true
                                                        } label: {
                                                            SLabel(
                                                                "Wi-Fi",
                                                                color: setting.color,
                                                                icon: setting.icon,
                                                                status: (wifiEnabled && !airplaneModeEnabled)
                                                                    ? (wifiDisplayName.isEmpty ? "Not Connected" : wifiDisplayName)
                                                                    : "Off"
                                                            )
                                                        }
                                                        .foregroundColor(.primary)
                                                        // Không set selection highlight để không giả điều hướng
                                                    } else {
                                                        Button {
                                                            id = UUID() // Reset destination
                                                            stateManager.selection = setting.type
                                                        } label: {
                                                            SLabel(
                                                                setting.id,
                                                                color: setting.color,
                                                                icon: setting.icon,
                                                                status: setting.id == "Bluetooth" ? (bluetoothEnabled ? "On" : "Off") : ""
                                                            )
                                                        }
                                                        .foregroundColor(.primary)
                                                        .listRowBackground(stateManager.selection == setting.type ? (UIDevice.IsSimulator ? Color.blue : .selected) : nil)
                                                    }
                                                }
                                            }

                                            if requiredCapabilities(capability: .vpn) {
                                                IconToggle("VPN", isOn: $VPNEnabled, color: .blue, icon: "network.connected.to.line.below")
                                            }
                                        }
                                    }

                                    // MARK: Main
                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: UIDevice.IsSimulator ? simulatorMainSettings : mainSettings)

                                    // MARK: Attention
                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: UIDevice.IsSimulator ? attentionSimulatorSettings : attentionSettings)

                                    // MARK: Security
                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: UIDevice.IsSimulator ? simulatorSecuritySettings : securitySettings)

                                    // MARK: Services
                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: UIDevice.IsSimulator ? simulatorServiceSettings : serviceSettings)

                                    // MARK: Apps
                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: appsSettings)

                                    // MARK: Developer
//                                    SettingsLabelSection(selection: $stateManager.selection, id: $id, item: developerSettings)
                                }
                                .navigationTitle("Settings")
                                .onAppear {
                                    isLandscape = geometry.size.width > geometry.size.height

                                    Task {
                                        withAnimation { preloadRect = false }
                                        try await Task.sleep(for: .seconds(1))
                                        withAnimation { preloadRect = true }
                                    }
                                }
                                .sheet(isPresented: $showingSignInSheet) {
                                    NavigationStack {
                                        SelectSignInOptionView()
                                            .interactiveDismissDisabled()
                                    }
                                }
                                .searchable(text: $searchText, isPresented: $searchFocused, placement: .navigationBarDrawer(displayMode: .automatic))
                                .overlay {
                                    if searchFocused {
                                        GeometryReader { geo in
                                            List {
                                                if searchText.isEmpty {
                                                    Section("Suggestions") {}
                                                } else {
                                                    ContentUnavailableView.search(text: searchText)
                                                        .frame(minHeight: 0, idealHeight: geo.size.height, maxHeight: .infinity)
                                                        .edgesIgnoringSafeArea(.all)
                                                        .listRowSeparator(.hidden)
                                                }
                                            }
                                            .scrollDisabled(!searchText.isEmpty)
                                            .listStyle(.inset)
                                        }
                                    }
                                }
                                .onChange(of: geometry.size.width) {
                                    isLandscape = geometry.size.width > geometry.size.height
                                }
                                .onChange(of: stateManager.selection) { // Change views when selecting sidebar navigation links
                                    if let selectedSettingsItem = combinedSettings.first(where: { $0.type == stateManager.selection }) {
                                        stateManager.destination = selectedSettingsItem.destination
                                    }
                                }
                            } else {
                                // MARK: - iOS Settings
                                List {
                                    Section { // Apple Account Section
                                        Button {
                                            showingSignInSheet.toggle()
                                        } label: {
                                            NavigationLink{} label: {
                                                AppleAccountSection()
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                        .sheet(isPresented: $showingSignInSheet) {
                                            NavigationStack {
                                                SelectSignInOptionView()
                                                    .interactiveDismissDisabled()
                                            }
                                        }
                                    }

                                    if siriEnabled && UIDevice.IntelligenceCapability {
                                        // MARK: TipKit Section
                                        Section {
                                            ImageCreationTipView()
                                        }
                                    }

                                    if !followUpDismissed && !UIDevice.IsSimulator {
                                        Section {
                                            SLink("FOLLOWUP_TITLE".localize(table: "FollowUp"), icon: "None", badgeCount: 1) {
                                                FollowUpView()
                                            }
                                        }
                                    }

                                    if !UIDevice.IsSimulator {
                                        // MARK: Radio Settings (iOS)
                                        Section {
                                            IconToggle("Airplane Mode", isOn: $airplaneModeEnabled, color: Color.orange, icon: "airplane")

                                            ForEach(radioSettings) { setting in
                                                if setting.capability == .none {
                                                    if setting.id == "Wi-Fi" {
                                                        SLink(
                                                            "Wi-Fi",
                                                            color: setting.color,
                                                            icon: setting.icon,
                                                            status: (wifiEnabled && !airplaneModeEnabled)
                                                                ? (wifiDisplayName.isEmpty ? "Not Connected" : wifiDisplayName)
                                                                : "Off"
                                                        ) {
                                                            setting.destination   // -> NetworkView
                                                        }
                                                        .accessibilityLabel("Wi-Fi")
                                                    } else {
                                                        SLink(
                                                            setting.id,
                                                            color: setting.color,
                                                            icon: setting.icon,
                                                            status: setting.id == "Bluetooth" ? (bluetoothEnabled ? "On" : "Off") : ""
                                                        ) { setting.destination }
                                                        .accessibilityLabel(setting.id)
                                                    }
                                                } else if requiredCapabilities(capability: setting.capability) {
                                                    SLink(setting.id,
                                                         color: setting.color,
                                                         icon: setting.icon,
                                                         status: setting.id == "Cellular" && airplaneModeEnabled ? "Airplane Mode" : setting.id == "Personal Hotspot" ? "Off" : ""
                                                    ) {
                                                        setting.destination
                                                    }
                                                    .disabled(setting.id == "Personal Hotspot" && airplaneModeEnabled)
                                                    .accessibilityLabel(setting.id)
                                                }
                                            }

                                            if requiredCapabilities(capability: .vpn) {
                                                IconToggle("VPN", isOn: $VPNEnabled, color: .blue, icon: "network.connected.to.line.below")
                                            }
                                        }
                                    }

                                    // MARK: Main Settings
                                    SettingsLinkSection(item: UIDevice.IsSimulator ? simulatorMainSettings : mainSettings)

                                    // MARK: Attention
                                    SettingsLinkSection(item: UIDevice.IsSimulator ? attentionSimulatorSettings : attentionSettings)

                                    // MARK: Security
                                    Section {
                                        let allItems = UIDevice.IsSimulator ? simulatorSecuritySettings : securitySettings
                                            let items = allItems.filter {            
                                                $0.id != "Touch ID & Mật mã" && $0.id != "Touch ID & Passcode"
                                            }
                                        ForEach(items) { setting in
                                            if setting.id == "Face ID & Mật mã" || setting.id == "Face ID & Passcode" {
                                                ZStack {
                                                    // 1) UI gốc
                                                    SLink(setting.id,
                                                          color: setting.color,
                                                          icon: setting.icon,
                                                          status: "") { setting.destination }
                                                    .allowsHitTesting(false)
                                                    NavigationLink(isActive: $navigateFaceID) {
                                                        (faceIDDestination ?? AnyView(EmptyView()))
                                                    } label: { EmptyView() }
                                                    .hidden()

                                                    Color.clear
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            faceIDDestination = AnyView(setting.destination)
                                                            if passcodeEnabled {
                                                                showFaceIDPasscodeSheet = true
                                                            } else {
                                                                navigateFaceID = true
                                                            }
                                                        }

                                                }
                                                .accessibilityLabel(setting.id)
                                            } else {
                                                SLink(setting.id,
                                                      color: setting.color,
                                                      icon: setting.icon,
                                                      status: "") {
                                                    setting.destination
                                                }
                                                .accessibilityLabel(setting.id)
                                            }
                                        }
                                    }

                                    // MARK: Services
                                    SettingsLinkSection(item: UIDevice.IsSimulator ? simulatorServiceSettings : serviceSettings)

                                    // MARK: Apps
                                    SettingsLinkSection(item: appsSettings)

                                    // MARK: Developer
//                                    if UIDevice.IsSimulator || configuration.developerMode {
//                                        SettingsLinkSection(item: developerSettings)
//                                    }
                                }
                                .navigationDestination(for: AnyRoute.self) { route in
                                    route.destination()
                                }
                                .navigationTitle("Settings")
                                .searchable(text: $searchText, isPresented: $searchFocused, placement: .navigationBarDrawer(displayMode: .automatic))
                                .overlay {
                                    if searchFocused {
                                        GeometryReader { geo in
                                            List {
                                                if searchText.isEmpty {
                                                    SettingsSearchView(stateManager: stateManager)
                                                } else {
                                                    ContentUnavailableView.search(text: searchText)
                                                        .frame(minHeight: 0, idealHeight: geo.size.height, maxHeight: .infinity)
                                                        .edgesIgnoringSafeArea(.all)
                                                        .listRowSeparator(.hidden)
                                                }
                                            }
                                            .scrollDisabled(!searchText.isEmpty)
                                            .listStyle(.inset)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: UIDevice.iPad ? (isLandscape ? 415 : 375) : nil)
                        if UIDevice.iPad {
                            NavigationStack(path: $stateManager.path) {
                                stateManager.destination
                                    .navigationDestination(for: AnyRoute.self) { route in
                                        route.destination()
                                    }
                            }
                            .id(id)
                        }
                    }
                }
                .onAppear {
                    try? Tips.configure()
                }
                .sheet(isPresented: $showWiFiEditor) {
                    NavigationStack {
                        Form {
                            Section(header: Text("Tên Wi-Fi")) {
                                TextField("Nhập tên mạng", text: $wifiDisplayName)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($wifiFieldFocused)
                                    .submitLabel(.done)
                                    .onSubmit { showWiFiEditor = false }
                            }
                            if !wifiEnabled || airplaneModeEnabled {
                                Text("Wi-Fi đang tắt hoặc ở Chế độ máy bay — tên sẽ hiển thị khi Wi‑Fi bật.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .navigationTitle("Wi‑Fi")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Hủy") { showWiFiEditor = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Xong") { showWiFiEditor = false }
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.async { wifiFieldFocused = true }
                        }
                    }
                    .presentationDetents([.height(180), .medium])
                    .presentationDragIndicator(.visible)
                }
                
                .sheet(isPresented: $showFaceIDPasscodeSheet) {
                    PasscodeSheet(
                        onCancel: { showFaceIDPasscodeSheet = false },
                        onSuccess: {
                            showFaceIDPasscodeSheet = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateFaceID = true
                            }
                        }
                    )
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(true)
                }
            }
        }
    }

    // MARK: - Required Capabilities Check
    @MainActor
    func requiredCapabilities(capability: Capabilities) -> Bool {
        switch capability {
        case .actionButton:
            return true
        case .appleIntelligence:
            return true
        case .cellular:
            return UIDevice.CellularTelephonyCapability
        case .ethernet:
            return false
        case .faceID:
            return UIDevice.PearlIDCapability
        case .isInternal:
            return false
        case .none:
            return true
        case .siri:
            return !UIDevice.IntelligenceCapability
        case .sounds:
            return UIDevice.iPad
        case .soundsHaptics:
            return UIDevice.iPhone
        case .touchID:
            return false
        case .vpn:
            return false
        }
    }

    #Preview {
        ContentView()
    }
