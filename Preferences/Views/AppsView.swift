//
//  AppsView.swift
//  Preferences
//
//  Settings > Apps
//

import SwiftUI

struct AppsView: View {
    // Variables
    @State private var searchText = String()

    /// App hệ thống (giữ nguyên của bạn)
    let apps = ["App Store", "Books", "Calendar", "Contacts", "Files", "Fitness", "Health", "Maps", "Messages", "News", "Passwords", "Photos", "Reminders", "Safari", "Shortcuts", "Translate"]

    /// App hệ thống khi chạy Simulator (giữ nguyên của bạn)
    let simulatorApps = ["Calendar", "Contacts", "Files", "Fitness", "Health", "Maps", "Messages", "News", "Passwords", "Photos", "Reminders", "Safari", "Shortcuts"]

    /// App BÊN NGOÀI (bạn có thể thêm/bớt tùy ý – icon đặt trong Assets theo quy ước `apple<name>`)
    let thirdPartyApps: [String] = [
        // A
        "ACB ONE", "Alibaba.com",
        // B
        "Biz MBBank", "Booking.com",
        // C
        "ChatGPT", "Cờ Tướng Haga",
        // D
        "DeepSeek", "Drive",
        // E
        "ExpressVPN",
        // F
        "Facebook",
        // G
        "Gmail", "Google", "Google Maps", "Grab",
        // H
        "Hanzii Dict", "Home Planner", "Hỗ trợ", "Huione",
        // I
        "Imou Life",
        // M
        "MB Bank", "Messenger", "MoMo", "MSB mBank", "MSB Merchant App", "My Viettel",
        // P
        "PayPal",
        // S
        "SantaPocket", "Sapo Nhà hàng", "Sapo Phục vụ", "Shopee", "SmartBanking", "SoundCloud",
        // T
        "Techcombank", "Telegram", "TestFlight", "TikTok",
    ]

    /// Gộp danh sách hiển thị
    var allApps: [String] {
        (UIDevice.IsSimulator ? simulatorApps : apps) + thirdPartyApps
    }

    /// Nhóm theo ký tự đầu (chuẩn hóa dấu tiếng Việt về chữ cái cơ bản để nhóm)
    var groupedApps: [String: [String]] {
        let groups = Dictionary(grouping: allApps) { app -> String in
            let first = app.trimmingCharacters(in: .whitespaces).first.map(String.init) ?? "#"
            // bỏ dấu cho mục đích group; riêng "Đ/đ" giữ nguyên
            if first.uppercased() == "Đ" { return "Đ" }
            let folded = first.folding(options: .diacriticInsensitive, locale: .current).uppercased()
            let letter = folded.range(of: "^[A-Z]$", options: .regularExpression) != nil ? folded : "#"
            return letter
        }
        // sort từng nhóm theo alphabet chuẩn người dùng
        var sorted = [String: [String]]()
        for (k, v) in groups {
            sorted[k] = v.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }
        return sorted
    }

    /// Dải chữ cái ở thanh index (có chữ Việt như iOS Settings)
    let letters = "AĂÂBCDĐEÊFGHIJKLMNOPQRSTUƯVWX YZ#".replacingOccurrences(of: " ", with: "")
    let table = "InstalledApps"
    
    var body: some View {
        ScrollViewReader { proxy in
            CustomList(title: "Apps".localize(table: table)) {
                // MARK: Default Apps
                SLink("Default Apps".localize(table: table),
                      color: .gray,
                      icon: "checkmark.rectangle.stack.fill",
                      subtitle: "Manage default apps on device".localize(table: table)) {
                    DefaultAppsView()
                }
                
                // MARK: Apps
                ForEach(groupedApps.keys.sorted(), id: \.self) { key in
                    Section(key) {
                        ForEach(groupedApps[key]!, id: \.self) { app in
                            // Icon vẫn theo quy ước "apple\(app)"
                            SLink(app, icon: "apple\(app)") {
                                switch app {
                                case "App Store":  AppStoreView()
                                case "Books":      BooksView()
                                case "Calendar":   CalendarView()
                                case "Contacts":   ContactsView()
                                case "Files":      FilesView()
                                case "Fitness":    BundleControllerView("FitnessSettings", controller: "FitnessSettingsController", title: "Fitness")
                                case "Health":     HealthView()
                                case "Maps":       MapsView()
                                case "Messages":   MessagesView()
                                case "News":       NewsView()
                                case "Passwords":  PasswordsView()
                                case "Photos":     PhotosView()
                                case "Reminders":
                                    if UIDevice.IsSimulator { EmptyView() } else { RemindersView() }
                                case "Safari":     SafariView()
                                case "Shortcuts":  ShortcutsView()
                                case "Translate":  TranslateView()
                                default:
                                    // App bên ngoài -> trang cấu hình chung
                                    ThirdPartyAppView(appName: app)
                                }
                            }
                        }
                    }
                    .id(key)
                }
                
                // MARK: Hidden Apps
                if UIDevice.IsSimulator {
                    Button {} label: {
                        SLink("Hidden Apps".localize(table: table), color: .gray, icon: "square.dashed") {}
                    }
                    .foregroundStyle(.primary)
                } else {
                    SLink("Hidden Apps".localize(table: table), color: .gray, icon: "square.dashed") {
                        ContentUnavailableView(
                            "No Hidden Apps".localize(table: table),
                            systemImage: "square.stack.3d.up.slash.fill",
                            description: Text("No hidden apps found.", tableName: table)
                        )
                    }
                }
            }
            .searchable(text: $searchText, placement: UIDevice.iPhone ? .navigationBarDrawer(displayMode: .always) : .toolbar)
            .scrollIndicators(.hidden)
            .overlay {
                // Index A-Z ở mép phải
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        ForEach(Array(letters), id: \.self) { letter in
                            let key = String(letter)
                            Text(key)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 15)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if groupedApps[key] != nil {
                                        proxy.scrollTo(key, anchor: .top)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

/// View cấu hình mặc định cho app bên ngoài
private struct ThirdPartyAppView: View {
    let appName: String
    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    Image("apple\(appName)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    Text(appName).font(.headline)
                }
                .padding(.vertical, 4)
            }
            Section("Quyền truy cập") {
                Toggle("Cho phép thông báo", isOn: .constant(true))
                Toggle("Dùng dữ liệu di động", isOn: .constant(true))
                Toggle("Làm mới nền", isOn: .constant(true))
            }
            Section("Dữ liệu") {
                Button(role: .destructive) { } label: {
                    Text("Xóa dữ liệu & bộ nhớ đệm")
                }
            }
        }
        .navigationTitle(appName)
    }
}

struct AppsRoute: Routable {
    func destination() -> AnyView {
        AnyView(AppsView())
    }
}

#Preview {
    NavigationStack {
        AppsView()
    }
}
