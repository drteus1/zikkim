import SwiftUI

struct CounterCard: View {
    let title: String
    let value: String
    let systemImage: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(gradient)
        )
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
}

