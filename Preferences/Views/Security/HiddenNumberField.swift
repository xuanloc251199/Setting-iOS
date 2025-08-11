import SwiftUI

/// UITextField ẩn để dùng bàn phím số hệ thống + secure entry
struct HiddenNumberField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.textColor = .clear
        tf.tintColor = .clear
        tf.backgroundColor = .clear
        tf.keyboardType = .numberPad
        tf.textContentType = .oneTimeCode
        // Đẩy text về SwiftUI mỗi khi thay đổi
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        // Tự focus để mở bàn phím
        DispatchQueue.main.async { tf.becomeFirstResponder() }
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if uiView.window != nil && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    // MARK: - MainActor để truy cập Binding an toàn
    @MainActor
    final class Coordinator: NSObject {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        @objc func textDidChange(_ sender: UITextField) {
            text = sender.text ?? ""
        }
    }
}
