import SwiftUI

@MainActor
struct PasscodeSheet: View {
    let onCancel: () -> Void
    let onSuccess: () -> Void

    @State private var digits: [String] = []
    @State private var passthrough = ""

    // --- Tuning theo ảnh iPhone 14 Pro Max ---
    private let topContentPadding: CGFloat = 132      // đẩy cụm nội dung xuống
    private let subtitleToDotsSpacing: CGFloat = 32   // giãn cách giữa title phụ & hàng chấm
    private let dotSize: CGFloat = 20                 // chấm nhỏ hơn
    private let dotStroke: CGFloat = 1.6              // viền xám mảnh
    private let dotSpacing: CGFloat = 28              // khoảng cách ngang giữa các chấm
    // ------------------------------------------------

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Thanh tiêu đề sheet
                    HStack {
                        Spacer(minLength: 44)
                        Text("Nhập mật mã")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        Button("Hủy", action: onCancel)
                            .font(.headline)
                            .tint(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    Spacer().frame(height: topContentPadding)

                    // Title phụ: nhỏ hơn, không đậm
                    Text("Nhập mật mã của bạn")
                        .font(.title3)                 // nhỏ hơn .title2
                        .fontWeight(.regular)          // không in đậm
                        .multilineTextAlignment(.center)

                    // Hàng 6 chấm
                    HStack(spacing: dotSpacing) {
                        ForEach(0..<6, id: \.self) { i in
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(UIColor.systemGray2), lineWidth: dotStroke)
                                if i < digits.count {
                                    Circle().fill(.black)     // đen đặc như ảnh
                                }
                            }
                            .frame(width: dotSize, height: dotSize)
                            .animation(.easeInOut(duration: 0.12), value: digits.count)
                        }
                    }
                    .padding(.top, subtitleToDotsSpacing)

                    Spacer()

                    // Trường nhập ẩn (bàn phím số hệ thống)
                    HiddenNumberField(text: $passthrough)
                        .frame(width: 0.1, height: 0.1)
                        .opacity(0.01)
                        .onChange(of: passthrough) { new in
                            var numbers = new.filter(\.isNumber)
                            if numbers.count > 6 { numbers = String(numbers.prefix(6)) }

                            let old = digits.count, now = numbers.count
                            if now > old {
                                for ch in numbers.dropFirst(old) {
                                    digits.append(String(ch))
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                if digits.count == 6 {
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        onSuccess()
                                        digits.removeAll()
                                        passthrough = ""
                                    }
                                }
                            } else if now < old {
                                digits.removeLast(old - now)
                            }
                            if passthrough != numbers { passthrough = numbers }
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
        }
    }
}
