import Foundation
import Combine
import Supabase

@MainActor
final class AchievementsViewModel: ObservableObject {
    // Local missions (defined in app)
    @Published var localMissions: [LocalMission] = MissionsData.missions
    @Published var completedMissionIds: Set<String> = []
    
    // Health milestones
    @Published var healthMilestones: [HealthMilestone] = HealthMilestonesData.milestones
    
    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Profile data for calculating progress
    private var quitDate: Date?

    private let client = SupabaseClientProvider.shared.client

    func load(authViewModel: AuthViewModel) async {
        guard let userId = authViewModel.session?.user.id else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Store quit date for health milestone calculations
        quitDate = authViewModel.profile?.quitAt

        do {
            // Load completed missions from database
            // We store mission_id as text to support local mission IDs
            let completions: [MissionCompletion] = try await client
                .from("mission_completions")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            completedMissionIds = Set(completions.map { $0.missionId })
        } catch {
            // Table might not exist yet - that's okay, we'll create it on first completion
            if let postgrestError = error as? PostgrestError, postgrestError.code == "42P01" {
                // Table doesn't exist - will be created on first save
                completedMissionIds = []
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Mission Completion
    
    func toggleMissionComplete(missionId: String, authViewModel: AuthViewModel) async {
        guard let userId = authViewModel.session?.user.id else { return }
        
        if completedMissionIds.contains(missionId) {
            // Uncomplete - remove from database
            await uncompleteMission(missionId: missionId, userId: userId)
        } else {
            // Complete - add to database
            await completeMission(missionId: missionId, userId: userId)
        }
    }
    
    private func completeMission(missionId: String, userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        let payload = MissionCompletionInsert(missionId: missionId, userId: userId)
        
        do {
            try await client
                .from("mission_completions")
                .insert(payload)
                .execute()
            
            completedMissionIds.insert(missionId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func uncompleteMission(missionId: String, userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client
                .from("mission_completions")
                .delete()
                .eq("user_id", value: userId)
                .eq("mission_id", value: missionId)
                .execute()
            
            completedMissionIds.remove(missionId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Health Milestone Progress
    
    func milestoneProgress(for milestone: HealthMilestone) -> Double {
        guard let quitDate = quitDate else { return 0 }
        
        let hoursSinceQuit = Date().timeIntervalSince(quitDate) / 3600
        let progress = hoursSinceQuit / milestone.hoursAfterQuit
        
        return min(max(progress, 0), 1) // Clamp between 0 and 1
    }
    
    func isMilestoneAchieved(_ milestone: HealthMilestone) -> Bool {
        milestoneProgress(for: milestone) >= 1.0
    }
    
    // MARK: - Statistics
    
    var completedMissionsCount: Int {
        completedMissionIds.count
    }
    
    var totalMissionsCount: Int {
        localMissions.count
    }
    
    var achievedMilestonesCount: Int {
        healthMilestones.filter { isMilestoneAchieved($0) }.count
    }
    
    var totalMilestonesCount: Int {
        healthMilestones.count
    }
    
    func missions(for category: MissionCategory) -> [LocalMission] {
        localMissions.filter { $0.category == category }
    }
    
    func isMissionCompleted(_ missionId: String) -> Bool {
        completedMissionIds.contains(missionId)
    }
}

// MARK: - Database Models

private struct MissionCompletion: Codable {
    let id: UUID
    let missionId: String
    let userId: UUID
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case missionId = "mission_id"
        case userId = "user_id"
        case completedAt = "completed_at"
    }
}

private struct MissionCompletionInsert: Encodable {
    let missionId: String
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case missionId = "mission_id"
        case userId = "user_id"
    }
}

