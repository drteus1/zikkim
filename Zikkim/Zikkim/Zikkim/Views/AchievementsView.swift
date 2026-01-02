import SwiftUI

enum AchievementTab: String, CaseIterable {
    case health = "Health"
    case missions = "Missions"
}

struct AchievementsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AchievementsViewModel()
    @State private var selectedTab: AchievementTab = .health

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segmented control
                segmentedControl
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Content
                TabView(selection: $selectedTab) {
                    healthMilestonesView
                        .tag(AchievementTab.health)
                    
                    missionsView
                        .tag(AchievementTab.missions)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Achievements")
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.load(authViewModel: authViewModel)
            }
            .refreshable {
                await viewModel.load(authViewModel: authViewModel)
            }
            .overlay(alignment: .bottom) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    // MARK: - Segmented Control
    
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(AchievementTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: tab == .health ? "heart.fill" : "target")
                                .font(.subheadline)
                            Text(tab.rawValue)
                                .fontWeight(.semibold)
                        }
                        
                        // Progress indicator
                        Text(tab == .health ? 
                             "\(viewModel.achievedMilestonesCount)/\(viewModel.totalMilestonesCount)" :
                             "\(viewModel.completedMissionsCount)/\(viewModel.totalMissionsCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selectedTab == tab ? 
                                  (tab == .health ? Color.pink.opacity(0.15) : Color.blue.opacity(0.15)) : 
                                  Color.clear)
                    )
                    .foregroundStyle(selectedTab == tab ? 
                                     (tab == .health ? .pink : .blue) : 
                                     .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - Health Milestones View
    
    private var healthMilestonesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Header stats
                healthStatsHeader
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Milestones list
                ForEach(viewModel.healthMilestones) { milestone in
                    HealthMilestoneRow(
                        milestone: milestone,
                        progress: viewModel.milestoneProgress(for: milestone),
                        isAchieved: viewModel.isMilestoneAchieved(milestone)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var healthStatsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Achieved",
                value: "\(viewModel.achievedMilestonesCount)",
                subtitle: "milestones",
                color: .green,
                icon: "checkmark.seal.fill"
            )
            
            StatCard(
                title: "In Progress",
                value: "\(viewModel.totalMilestonesCount - viewModel.achievedMilestonesCount)",
                subtitle: "remaining",
                color: .orange,
                icon: "hourglass"
            )
        }
    }
    
    // MARK: - Missions View
    
    private var missionsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header stats
                missionsStatsHeader
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Missions by category
                ForEach(MissionCategory.allCases) { category in
                    let categoryMissions = viewModel.missions(for: category)
                    if !categoryMissions.isEmpty {
                        MissionCategorySection(
                            category: category,
                            missions: categoryMissions,
                            viewModel: viewModel,
                            authViewModel: authViewModel
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var missionsStatsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Completed",
                value: "\(viewModel.completedMissionsCount)",
                subtitle: "missions",
                color: .blue,
                icon: "checkmark.circle.fill"
            )
            
            StatCard(
                title: "Remaining",
                value: "\(viewModel.totalMissionsCount - viewModel.completedMissionsCount)",
                subtitle: "to unlock",
                color: .purple,
                icon: "lock.fill"
            )
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Health Milestone Row

private struct HealthMilestoneRow: View {
    let milestone: HealthMilestone
    let progress: Double
    let isAchieved: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isAchieved ? Color.green.opacity(0.15) : Color.pink.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isAchieved ? "checkmark.seal.fill" : milestone.icon)
                        .font(.title2)
                        .foregroundStyle(isAchieved ? .green : .pink)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(milestone.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        if isAchieved {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(milestone.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Time indicator
                    Text(timeDescription)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isAchieved ? .green : .orange)
                        .padding(.top, 2)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: isAchieved ? [.green, .mint] : [.pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var timeDescription: String {
        let hours = milestone.hoursAfterQuit
        
        if hours < 1 {
            return "\(Int(hours * 60)) minutes after quitting"
        } else if hours < 24 {
            return "\(Int(hours)) hours after quitting"
        } else if hours < 168 {
            let days = Int(hours / 24)
            return "\(days) day\(days == 1 ? "" : "s") after quitting"
        } else if hours < 720 {
            let weeks = Int(hours / 168)
            return "\(weeks) week\(weeks == 1 ? "" : "s") after quitting"
        } else if hours < 8760 {
            let months = Int(hours / 720)
            return "\(months) month\(months == 1 ? "" : "s") after quitting"
        } else {
            let years = Int(hours / 8760)
            return "\(years) year\(years == 1 ? "" : "s") after quitting"
        }
    }
}

// MARK: - Mission Category Section

private struct MissionCategorySection: View {
    let category: MissionCategory
    let missions: [LocalMission]
    let viewModel: AchievementsViewModel
    let authViewModel: AuthViewModel
    
    private var completedCount: Int {
        missions.filter { viewModel.isMissionCompleted($0.id) }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text("\(completedCount)/\(missions.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(category.color.opacity(0.1))
                    )
            }
            .padding(.horizontal)
            
            // Missions
            VStack(spacing: 8) {
                ForEach(missions) { mission in
                    MissionRow(
                        mission: mission,
                        isCompleted: viewModel.isMissionCompleted(mission.id),
                        categoryColor: category.color
                    ) {
                        Task {
                            await viewModel.toggleMissionComplete(
                                missionId: mission.id,
                                authViewModel: authViewModel
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Mission Row

private struct MissionRow: View {
    let mission: LocalMission
    let isCompleted: Bool
    let categoryColor: Color
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isCompleted ? categoryColor : Color(.systemGray3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Circle()
                            .fill(categoryColor)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                
                // Icon
                Image(systemName: mission.icon)
                    .font(.title3)
                    .foregroundStyle(isCompleted ? categoryColor : .secondary)
                    .frame(width: 28)
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(mission.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted, color: .secondary)
                    
                    Text(mission.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isCompleted ? categoryColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
