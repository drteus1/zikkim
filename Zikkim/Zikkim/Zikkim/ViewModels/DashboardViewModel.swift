import Foundation
import Combine
import Supabase

struct DashboardStats {
    let elapsed: TimeInterval
    let cigarettesAvoided: Double
    let moneySaved: Double
    let lifeMinutesRegained: Double
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats(elapsed: 0, cigarettesAvoided: 0, moneySaved: 0, lifeMinutesRegained: 0)
    @Published var milestoneProgress: [(HealthMilestone, Double)] = []
    @Published var isLoggingCraving = false
    @Published var errorMessage: String?

    private var profile: Profile?
    private var tickerTask: Task<Void, Never>?
    private let cigarettesPerPack = 20.0
    private let lifeMinutesPerCigarette = 11.0
    private let client = SupabaseClientProvider.shared.client

    func configure(profile: Profile?) {
        self.profile = profile
        updateStats()
        computeMilestones()
        startTimer()
    }

    func startTimer() {
        tickerTask?.cancel()
        guard profile != nil else { return }
        tickerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self?.updateStats()
                }
            }
        }
    }

    func stopTimer() {
        tickerTask?.cancel()
        tickerTask = nil
    }

    func updateStats() {
        guard let profile else { return }
        let elapsed = max(0, Date().timeIntervalSince(profile.quitAt))

        let cigsPerSecond = Double(profile.cigarettesPerDay) / (24 * 60 * 60)
        let cigarettesAvoided = elapsed * cigsPerSecond
        let moneySaved = (cigarettesAvoided / cigarettesPerPack) * profile.pricePerPack
        let lifeMinutesRegained = cigarettesAvoided * lifeMinutesPerCigarette

        stats = DashboardStats(
            elapsed: elapsed,
            cigarettesAvoided: cigarettesAvoided,
            moneySaved: moneySaved,
            lifeMinutesRegained: lifeMinutesRegained
        )

        computeMilestones()
    }

    func computeMilestones() {
        guard let profile else {
            milestoneProgress = []
            return
        }
        let elapsedHours = Date().timeIntervalSince(profile.quitAt) / 3600
        milestoneProgress = HealthMilestonesData.milestones.map { milestone in
            let progress = max(0, min(1, elapsedHours / milestone.hoursAfterQuit))
            return (milestone, progress)
        }
    }

    func logCraving(intensity: Int? = nil, trigger: String? = nil, note: String? = nil) async {
        guard let userId = profile?.userId else { return }
        isLoggingCraving = true
        defer { isLoggingCraving = false }

        let payload = CravingInsert(userId: userId, intensity: intensity, triggerText: trigger, note: note)
        do {
            _ = try await client
                .from("cravings")
                .insert(payload)
                .execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct CravingInsert: Encodable {
    let userId: UUID
    let loggedAt: Date = Date()
    let intensity: Int?
    let triggerText: String?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case loggedAt = "logged_at"
        case intensity
        case triggerText = "trigger_text"
        case note
    }
}

