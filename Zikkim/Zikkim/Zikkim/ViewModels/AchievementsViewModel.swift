import Foundation
import Combine
import Supabase

@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var missions: [Mission] = []
    @Published var progress: [UUID: MissionProgress] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    func load(authViewModel: AuthViewModel) async {
        guard let userId = authViewModel.session?.user.id else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched: [Mission] = try await client
                .from("missions")
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
            missions = fetched

            let prog: [MissionProgress] = try await client
                .from("mission_progress")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            progress = Dictionary(uniqueKeysWithValues: prog.map { ($0.missionId, $0) })
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markCompleted(missionId: UUID, note: String? = nil, authViewModel: AuthViewModel) async {
        guard let userId = authViewModel.session?.user.id else { return }
        isLoading = true
        defer { isLoading = false }
        let payload = MissionProgressInsert(missionId: missionId, userId: userId, status: "completed", note: note)
        do {
            let inserted: MissionProgress = try await client
                .from("mission_progress")
                .upsert(payload, returning: .representation)
                .select()
                .single()
                .execute()
                .value
            progress[missionId] = inserted
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct MissionProgressInsert: Encodable {
    let missionId: UUID
    let userId: UUID
    let status: String
    let note: String?

    enum CodingKeys: String, CodingKey {
        case missionId = "mission_id"
        case userId = "user_id"
        case status
        case note
    }
}

