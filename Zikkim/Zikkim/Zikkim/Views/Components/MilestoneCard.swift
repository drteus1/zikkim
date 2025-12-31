import SwiftUI

struct MilestoneCard: View {
    let milestone: HealthMilestone
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: milestone.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading) {
                    Text(milestone.title)
                        .font(.headline)
                    Text(milestone.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.blue)
            Text(progressText(progress))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func progressText(_ progress: Double) -> String {
        switch progress {
        case ..<0.05:
            return "Just started"
        case ..<0.25:
            return "Making progress"
        case ..<0.75:
            return "Stay consistent"
        case ..<1.0:
            return "Almost there"
        default:
            return "Milestone achieved"
        }
    }
}

