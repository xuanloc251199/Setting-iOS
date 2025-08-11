import SwiftUI

/// Màn hình đích “Face ID & Mật mã”
struct FaceIDPasscodeScreen: View {
    @State private var unlockiPhone = true
    @State private var appStore = true
    @State private var wallet = false

    var body: some View {
        List {
            Section(header: Text("Face ID")) {
                Toggle(isOn: $unlockiPhone) { Text("Mở khóa iPhone") }
                Toggle(isOn: $appStore) { Text("iTunes & App Store") }
                Toggle(isOn: $wallet) { Text("Ví & Apple Pay") }
            }
            Section(header: Text("Mật mã")) {
                NavigationLink("Thay đổi mật mã") {
                    Text("Flow thay đổi mật mã (demo)")
                        .navigationTitle("Thay đổi mật mã")
                }
                Button(role: .destructive) { } label: { Text("Tắt Mật mã") }
            }
            Section(footer: Text("Màn hình mô phỏng để bám sát UI iOS 18.")) { EmptyView() }
        }
        .navigationTitle("Face ID & Mật mã")
        .navigationBarTitleDisplayMode(.inline)
    }
}
