import SwiftUI

struct HighBrightnessTip: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .padding(8)
                .background(Circle().fill(.blue))

            VStack(alignment: .leading, spacing: 3) {
                Text("Độ sáng cao")
                    .font(.headline)
                Text("Độ sáng màn hình cao tiêu thụ mức năng lượng lớn. Hãy cân nhắc giảm độ sáng để cải thiện thời lượng pin.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HighBrightnessTip()
        .padding()
        .background(Color(.systemGroupedBackground))
}
