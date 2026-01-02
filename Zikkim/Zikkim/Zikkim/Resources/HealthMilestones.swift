import Foundation

enum HealthMilestonesData {
    static let milestones: [HealthMilestone] = [
        // Minutes to hours
        HealthMilestone(
            title: "Pulse normalizes",
            detail: "Heart rate and blood pressure begin to drop to normal levels.",
            hoursAfterQuit: 0.33, // 20 minutes
            icon: "heart.fill"
        ),
        HealthMilestone(
            title: "CO cleared",
            detail: "Carbon monoxide levels in blood drop; oxygen levels rise.",
            hoursAfterQuit: 8,
            icon: "lungs.fill"
        ),
        HealthMilestone(
            title: "Heart attack risk drops",
            detail: "Your chance of a heart attack begins to decrease.",
            hoursAfterQuit: 24, // 1 day
            icon: "bolt.heart.fill"
        ),
        
        // Days
        HealthMilestone(
            title: "Sense of taste returns",
            detail: "Nerve endings start recovering and senses improve.",
            hoursAfterQuit: 48, // 2 days
            icon: "fork.knife"
        ),
        HealthMilestone(
            title: "Nicotine leaves body",
            detail: "All nicotine has been metabolized and eliminated.",
            hoursAfterQuit: 72, // 3 days
            icon: "leaf.fill"
        ),
        
        // Weeks
        HealthMilestone(
            title: "Breathing improves",
            detail: "Bronchial tubes begin to relax and open up.",
            hoursAfterQuit: 168, // 1 week
            icon: "wind"
        ),
        HealthMilestone(
            title: "Lung function improves",
            detail: "Cilia regrow; breathing becomes easier.",
            hoursAfterQuit: 336, // 2 weeks
            icon: "waveform.path.ecg"
        ),
        HealthMilestone(
            title: "Circulation restored",
            detail: "Blood circulation significantly improves throughout your body.",
            hoursAfterQuit: 720, // 1 month
            icon: "arrow.triangle.2.circlepath"
        ),
        
        // Months
        HealthMilestone(
            title: "Coughing decreases",
            detail: "Cilia are fully functional; lungs are cleaner.",
            hoursAfterQuit: 2160, // 3 months
            icon: "bubbles.and.sparkles.fill"
        ),
        HealthMilestone(
            title: "Energy boost",
            detail: "Fatigue and shortness of breath decrease dramatically.",
            hoursAfterQuit: 4320, // 6 months
            icon: "bolt.fill"
        ),
        
        // Years
        HealthMilestone(
            title: "Heart risk halves",
            detail: "Risk of heart disease is now half that of a smoker.",
            hoursAfterQuit: 8760, // 1 year
            icon: "heart.circle.fill"
        ),
        HealthMilestone(
            title: "Stroke risk drops",
            detail: "Your stroke risk begins to approach that of a non-smoker.",
            hoursAfterQuit: 43800, // 5 years
            icon: "brain.head.profile"
        ),
        HealthMilestone(
            title: "Lung cancer risk halves",
            detail: "Risk of lung cancer is now half that of a continuing smoker.",
            hoursAfterQuit: 87600, // 10 years
            icon: "shield.checkered"
        ),
        HealthMilestone(
            title: "Heart disease risk normal",
            detail: "Your risk is now the same as someone who never smoked.",
            hoursAfterQuit: 131400, // 15 years
            icon: "star.fill"
        )
    ]
}

