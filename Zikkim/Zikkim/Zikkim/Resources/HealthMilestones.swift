import Foundation

enum HealthMilestonesData {
    static let milestones: [HealthMilestone] = [
        HealthMilestone(
            title: "Pulse normalizes",
            detail: "Heart rate and blood pressure begin to drop to normal levels.",
            hoursAfterQuit: 0.33,
            icon: "heart.fill"
        ),
        HealthMilestone(
            title: "CO cleared",
            detail: "Carbon monoxide levels in blood drop; oxygen levels rise.",
            hoursAfterQuit: 8,
            icon: "lungs.fill"
        ),
        HealthMilestone(
            title: "Sense of taste returns",
            detail: "Nerve endings start recovering and senses improve.",
            hoursAfterQuit: 48,
            icon: "fork.knife"
        ),
        HealthMilestone(
            title: "Lung function improves",
            detail: "Cilia regrow; breathing becomes easier.",
            hoursAfterQuit: 336, // 2 weeks
            icon: "waveform.path.ecg"
        ),
        HealthMilestone(
            title: "Heart risk drops",
            detail: "Risk of heart disease halves compared to a smoker.",
            hoursAfterQuit: 8760, // 1 year
            icon: "bolt.heart"
        ),
        HealthMilestone(
            title: "Stroke risk nears normal",
            detail: "Risk approaches that of a non-smoker.",
            hoursAfterQuit: 35040, // 4 years
            icon: "brain.head.profile"
        )
    ]
}

