import SwiftUI

/// Fake passcode modal — accepts any input and calls onComplete when user taps Continue.
struct FakePasscodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var passcode: String = ""
    @FocusState private var focused: Bool

    /// called when user finishes input and wants to continue
    var onComplete: (() -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer().frame(height: 6)

                Text("Nhập mật mã")
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)

                Text("Nhập bất kỳ mật mã để vào Face ID & Mật Mã.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // simple secure field; we use .numberPad for convenience but any keyboard is ok
                SecureField("●●●●●●", text: $passcode)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 260)
                    .padding(.top, 6)

                // optional hint
                Text("Bạn có thể nhập bất kỳ mật mã nào.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    // call completion then dismiss sheet
                    onComplete?()
                    dismiss()
                } label: {
                    Text("Tiếp tục")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(false) // intentionally allow any value

                Button("Hủy") { dismiss() }
                    .padding(.top, 6)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nhập mật mã").font(.headline)
                }
            }
            .onAppear {
                // focus field right away
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { focused = true }
            }
        }
    }
}
