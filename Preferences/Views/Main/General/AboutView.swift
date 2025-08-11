//
//  AboutView.swift
//  Preferences
//
//  Settings > General > About
//

import SwiftUI
import UIKit

struct AboutView: View {
    // Editable values stored in AppStorage so edits persist
    @AppStorage("DeviceName") private var deviceName = UIDevice.current.model
    @AppStorage("OSVersion") private var osVersion = String()
    @AppStorage("ProductModelName") private var productModelName = String()
    @AppStorage("ModelNumber") private var modelNumber = String()
    @AppStorage("RegulatoryModelNumber") private var regulatoryModelNumber = String()
    @AppStorage("SerialNumber") private var serialNumber = String()
    @AppStorage("CapacityStorage") private var capacityStorage = String()
    @AppStorage("AvailableStorage") private var availableStorage = String()
    @AppStorage("WifiAddress") private var wifiAddress = String()
    @AppStorage("BluetoothAddress") private var bluetoothAddress = String()
    @AppStorage("EIDValue") private var eidValue = String()
    @AppStorage("ModemIMEI") private var modemIMEI = String()
    @AppStorage("ModemIMEI2") private var modemIMEI2 = String()
    
    // New editable fields
    @AppStorage("SongsCount") private var songsCount = "0"
    @AppStorage("VideosCount") private var videosCount = "0"
    @AppStorage("PhotosCount") private var photosCount = "0"
    @AppStorage("AppsCount") private var appsCount = "0"

    // Local UI state
    @State private var showingModelNumber = false
    @State private var activeEdit: EditField? = nil
    @State private var quickCopyActiveID: String? = nil   // track mục đang mở menu

    let table = "General"
    let UITable = "GeneralSettingsUI"

    var body: some View {
        CustomList(title: "About".localize(table: table)) {
            // MARK: - Main device info
            Section {
                if UIDevice.IsSimulator {
                    LabeledContent("Device_Name".localize(table: table), value: UIDevice.current.model)
                        .quickCopy(id: "deviceName", value: UIDevice.current.model, active: $quickCopyActiveID)
                } else {
                    SettingsLink("Device_Name".localize(table: table),
                                 status: deviceName,
                                 destination: NameView())
                    .quickCopy(id: "deviceName", value: deviceName, active: $quickCopyActiveID)
                }

                Button { activeEdit = .osVersion } label: {
                    LabeledContent("OS Version".localize(table: UITable),
                                   value: osVersion.isEmpty ? UIDevice().systemVersion : osVersion)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "osVersion",
                           value: osVersion.isEmpty ? UIDevice().systemVersion : osVersion,
                           active: $quickCopyActiveID)

                Button { activeEdit = .productModelName } label: {
                    LabeledContent("ProductModelName".localize(table: UITable),
                                   value: productModelName.isEmpty ? UIDevice.fullModel : productModelName)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .textSelection(.enabled)
                .quickCopy(id: "productModelName",
                           value: productModelName.isEmpty ? UIDevice.fullModel : productModelName,
                           active: $quickCopyActiveID)

                MonospacedLabel("ProductModel".localize(table: UITable),
                                value: showingModelNumber ? regulatoryModelNumber : "\(modelNumber)\(getRegionInfo())")
                    .contentShape(Rectangle())
                    .onTapGesture { showingModelNumber.toggle() }
                    .onLongPressGesture { activeEdit = .modelNumber }
                    .contextMenu {
                        Button("Edit Model Number") { activeEdit = .modelNumber }
                        Button("Edit Regulatory Model") { activeEdit = .regulatoryModelNumber }
                    }
                    .quickCopy(id: "modelNumber",
                               value: showingModelNumber ? regulatoryModelNumber : "\(modelNumber)\(getRegionInfo())",
                               active: $quickCopyActiveID)

                Button { activeEdit = .serialNumber } label: {
                    LabeledContent("SerialNumber".localize(table: UITable), value: serialNumber)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "serialNumber", value: serialNumber, active: $quickCopyActiveID)
            }
            .task {
                if osVersion.isEmpty { osVersion = UIDevice().systemVersion }
                if productModelName.isEmpty { productModelName = UIDevice.fullModel }
                if serialNumber.isEmpty { serialNumber = MGHelper.read(key: "VasUgeSzVyHdB27g2XpN0g") ?? getRandomSerialNumber() }
                if modelNumber.isEmpty { modelNumber = MGHelper.read(key: "D0cJ8r7U5zve6uA6QbOiLA") ?? getRegulatoryModelNumber() }
                if regulatoryModelNumber.isEmpty { regulatoryModelNumber = getRegulatoryModelNumber() }
                if wifiAddress.isEmpty { wifiAddress = generateRandomAddress() }
                if bluetoothAddress.isEmpty { bluetoothAddress = generateRandomAddress() }
                if eidValue.isEmpty { eidValue = getRandomEID() }
                if capacityStorage.isEmpty { capacityStorage = UIDevice.storageCapacity ?? getTotalStorage()! }
                if availableStorage.isEmpty { availableStorage = getAvailableStorage() ?? "Error" }
                if modemIMEI.isEmpty { modemIMEI = "00 000000 000000 0" }
                if modemIMEI2.isEmpty { modemIMEI2 = "00 000000 000000 0" }
            }

            // MARK: - Storage / counts
            Section {
                Button { activeEdit = .songs } label: {
                    LabeledContent("SONGS".localize(table: UITable), value: songsCount)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "songs", value: songsCount, active: $quickCopyActiveID)

                Button { activeEdit = .videos } label: {
                    LabeledContent("VIDEOS".localize(table: UITable), value: videosCount)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "videos", value: videosCount, active: $quickCopyActiveID)

                Button { activeEdit = .photos } label: {
                    LabeledContent("PHOTOS".localize(table: UITable), value: photosCount)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "photos", value: photosCount, active: $quickCopyActiveID)

                if !UIDevice.IsSimulator {
                    Button { activeEdit = .apps } label: {
                        LabeledContent("APPLICATIONS".localize(table: UITable), value: appsCount)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .quickCopy(id: "apps", value: appsCount, active: $quickCopyActiveID)
                }

                Button { activeEdit = .capacity } label: {
                    LabeledContent("User Data Capacity".localize(table: UITable), value: capacityStorage)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "capacity", value: capacityStorage, active: $quickCopyActiveID)

                Button { activeEdit = .available } label: {
                    LabeledContent("User Data Available".localize(table: UITable), value: availableStorage)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .quickCopy(id: "available", value: availableStorage, active: $quickCopyActiveID)
            }

            // MARK: - Network & identifiers
            if !UIDevice.IsSimulator {
                MonospacedLabel("MACAddress".localize(table: UITable), value: wifiAddress)
                    .contentShape(Rectangle())
                    .onTapGesture { activeEdit = .wifi }
                    .quickCopy(id: "wifi", value: wifiAddress, active: $quickCopyActiveID)

                MonospacedLabel("BTMACAddress".localize(table: UITable), value: bluetoothAddress)
                    .contentShape(Rectangle())
                    .onTapGesture { activeEdit = .bluetooth }
                    .quickCopy(id: "bt", value: bluetoothAddress, active: $quickCopyActiveID)

                if UIDevice.CellularTelephonyCapability {
                    MonospacedLabel("ModemVersion".localize(table: UITable), value: "1.00.00")
                        .quickCopy(id: "modemVersion", value: "1.00.00", active: $quickCopyActiveID)
                }

                Button { activeEdit = .seid } label: {
                    Text("SEID")
                }
                .buttonStyle(.plain)
                .quickCopy(id: "seidLabel", value: "SEID", active: $quickCopyActiveID)

                if UIDevice.CellularTelephonyCapability {
                    VStack {
                        Text("EID", tableName: table)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 0) {
                            ForEach(Array(eidValue.enumerated()), id: \.offset) { _, character in
                                let char = String(character)
                                if character == "1" {
                                    Text(char)
                                } else {
                                    Text(char)
                                        .fontDesign(.monospaced)
                                        .kerning(-1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    }
                    .quickCopy(id: "eid", value: eidValue, active: $quickCopyActiveID)

                    LabeledContent("CARRIER_LOCK".localize(table: table),
                                   value: "CARRIER_LOCK_UNLOCKED".localize(table: table))
                    .quickCopy(id: "carrierLock",
                               value: "CARRIER_LOCK_UNLOCKED".localize(table: table),
                               active: $quickCopyActiveID)

                    Section {
                        MonospacedLabel("ModemIMEI".localize(table: UITable), value: modemIMEI)
                            .onTapGesture { activeEdit = .modemIMEI }
                            .quickCopy(id: "imei1", value: modemIMEI, active: $quickCopyActiveID)

                        MonospacedLabel("IMEI2".localize(table: UITable), value: modemIMEI2)
                            .onTapGesture { activeEdit = .modemIMEI2 }
                            .quickCopy(id: "imei2", value: modemIMEI2, active: $quickCopyActiveID)
                    } header: {
                        Text("AVAILABLE_SIMS".localize(table: table))
                    }
                }
            }

            // MARK: - Cert trust link
            Section {
                Button { activeEdit = .certTrust } label: {
                    HStack {
                        Text("CERT_TRUST_SETTINGS".localize(table: UITable))
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .quickCopy(id: "certTrust", value: "CERT_TRUST_SETTINGS".localize(table: UITable), active: $quickCopyActiveID)
            }
        }
        .sheet(item: $activeEdit) { field in
            switch field {
            case .osVersion: EditView(title: "OS Version", value: $osVersion)
            case .productModelName: EditView(title: "Product Model Name", value: $productModelName)
            case .modelNumber: EditView(title: "Model Number", value: $modelNumber)
            case .regulatoryModelNumber: EditView(title: "Regulatory Model Number", value: $regulatoryModelNumber)
            case .serialNumber: EditView(title: "Serial Number", value: $serialNumber)
            case .capacity: EditView(title: "Capacity", value: $capacityStorage)
            case .available: EditView(title: "Available", value: $availableStorage)
            case .wifi: EditView(title: "Wi-Fi Address", value: $wifiAddress)
            case .bluetooth: EditView(title: "Bluetooth Address", value: $bluetoothAddress)
            case .eid: EditView(title: "EID", value: $eidValue)
            case .modemIMEI: EditView(title: "Modem IMEI", value: $modemIMEI)
            case .modemIMEI2: EditView(title: "Modem IMEI 2", value: $modemIMEI2)
            case .songs: EditView(title: "Songs", value: $songsCount)
            case .videos: EditView(title: "Videos", value: $videosCount)
            case .photos: EditView(title: "Photos", value: $photosCount)
            case .apps: EditView(title: "Applications", value: $appsCount)
            case .seid: SEIDView()
            case .certTrust:
                BundleControllerView("/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/GeneralSettingsUI",
                                     controller: "PSGCertTrustSettings",
                                     title: "CERT_TRUST_SETTINGS",
                                     table: UITable)
            }
        }
    }

    // MARK: - Helpers
    private func getRegionInfo() -> String {
        if let mobileGestalt = UIDevice.checkDevice() {
            let cacheExtra = mobileGestalt["CacheExtra"] as! [String : AnyObject]
            return cacheExtra["zHeENZu+wbg7PUprwNwBWg"] as! String
        }
        return "LL/A"
    }

    private func getRegulatoryModelNumber() -> String {
        if let answer = MGHelper.read(key: "97JDvERpVwO+GHtthIh7hA") {
            return answer
        }
        if let mobileGestalt = UIDevice.checkDevice() {
            let cacheExtra = mobileGestalt["CacheExtra"] as! [String : AnyObject]
            return cacheExtra["97JDvERpVwO+GHtthIh7hA"] as! String
        }
        return "Error"
    }

    private func getRandomSerialNumber() -> String {
        let letters = "BCDFGHJKLMNPQRTVWXYZ0123456789"
        var random = SystemRandomNumberGenerator()
        var s = String()
        for _ in 0..<10 {
            let i = Int(random.next(upperBound: UInt32(letters.count)))
            s.append(letters[letters.index(letters.startIndex, offsetBy: i)])
        }
        return s
    }

    private func getRandomEID() -> String {
        let lowerBound = "10000000000000000000000000000000"
        let upperBound = "99999999999999999999999999999999"
        var rs = String()
        for i in 0..<lowerBound.count {
            let ld = lowerBound[lowerBound.index(lowerBound.startIndex, offsetBy: i)].wholeNumberValue!
            let ud = upperBound[upperBound.index(upperBound.startIndex, offsetBy: i)].wholeNumberValue!
            rs += String(Int.random(in: ld...ud))
        }
        return rs
    }
}

// MARK: - Edit sheet view
struct EditView: View {
    let title: String
    @Binding var value: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField(title, text: $value)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Active edit field enum
enum EditField: String, Identifiable {
    var id: String { rawValue }
    case osVersion, productModelName, modelNumber, regulatoryModelNumber, serialNumber
    case capacity, available, wifi, bluetooth, eid, modemIMEI, modemIMEI2
    case songs, videos, photos, apps
    case seid, certTrust
}

// KEEP generateRandomAddress and storage helpers unchanged
func generateRandomAddress() -> String {
    let characters = "0123456789ABCDEF"
    var address = String()
    for i in 0..<6 {
        if i > 0 { address += ":" }
        let byte = (0..<2).map { _ in characters.randomElement()! }
        address += String(byte)
    }
    return address
}

func getAvailableStorage() -> String? {
    let fm = FileManager.default
    do {
        let attrs = try fm.attributesOfFileSystem(forPath: NSHomeDirectory())
        if let free = attrs[.systemFreeSize] as? NSNumber {
            let bytes = free.int64Value
            let fmt = ByteCountFormatter()
            fmt.allowedUnits = [.useGB]
            fmt.countStyle = .file
            return fmt.string(fromByteCount: bytes)
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return nil
}

func getTotalStorage() -> String? {
    let fm = FileManager.default
    do {
        let attrs = try fm.attributesOfFileSystem(forPath: NSHomeDirectory())
        if let total = attrs[.systemSize] as? NSNumber {
            let bytes = total.int64Value
            let fmt = ByteCountFormatter()
            fmt.allowedUnits = [.useGB]
            fmt.countStyle = .file
            return fmt.string(fromByteCount: bytes)
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return "Error"
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

// =======================================================
// MARK: - System Copy Bubble (iOS 18 via UIMenuController)
// =======================================================

private final class CopyMenuHost: UIView {
    var textToCopy: String = ""
    override var canBecomeFirstResponder: Bool { true }

    // ĐỔI TÊN để tránh xung đột
    @objc func performCopy(_ sender: Any?) {
        UIPasteboard.general.string = textToCopy
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action == #selector(performCopy(_:))
    }

    func presentMenu() {
        becomeFirstResponder()
        // Sử dụng selector mới
        let item = UIMenuItem(title: "Sao chép", action: #selector(performCopy(_:)))
        let menu = UIMenuController.shared
        menu.menuItems = [item]
        // anchor giữa hàng để bubble nằm đúng vị trí
        let r = CGRect(x: bounds.midX - 1, y: bounds.midY - 1, width: 2, height: 2)
        menu.showMenu(from: self, rect: r)
    }
}

private struct CopyMenuBridge: UIViewRepresentable {
    @Binding var hostRef: CopyMenuHost?
    let text: String

    func makeUIView(context: Context) -> CopyMenuHost {
        let v = CopyMenuHost()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        v.textToCopy = text
        DispatchQueue.main.async { hostRef = v }
        return v
    }

    func updateUIView(_ uiView: CopyMenuHost, context: Context) {
        uiView.textToCopy = text
    }
}

private struct QuickCopyModifier: ViewModifier {
    let id: String
    let valueToCopy: String
    @Binding var activeID: String?

    @State private var host: CopyMenuHost?

    func body(content: Content) -> some View {
        content
            .background(CopyMenuBridge(hostRef: $host, text: valueToCopy).allowsHitTesting(false))
            .simultaneousGesture(TapGesture(count: 2).onEnded { present() })                // double-tap
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in     // long-press
                present()
            })
    }

    private func present() {
        activeID = id
        host?.presentMenu()
    }
}

private extension View {
    /// Gắn bubble "Sao chép" mặc định iOS 18 cho một hàng. `id` phải duy nhất.
    func quickCopy(id: String, value: String, active: Binding<String?>) -> some View {
        modifier(QuickCopyModifier(id: id, valueToCopy: value, activeID: active))
    }
}
