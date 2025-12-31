import SwiftUI

struct CravingButton: View {
    let action: () -> Void
    let isLoading: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                Text(isLoading ? "Logging..." : "Log craving now")
                    .fontWeight(.semibold)
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            .padding()
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [.pink, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
        }
        .disabled(isLoading)
    }
}

