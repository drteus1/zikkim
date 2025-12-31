import Foundation

struct HealthMilestone: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let hoursAfterQuit: Double
    let icon: String
}

