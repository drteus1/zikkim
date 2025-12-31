import Foundation
import Combine
import Supabase
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseClientProvider.shared.client

    init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        do {
            session = try await client.auth.session
        } catch {
            session = nil
        }

        if session == nil {
            // No silent fallback; user must sign in via SIWA flow.
            errorMessage = nil
        } else {
            await loadProfile()
        }
    }

    @discardableResult
    func signInWithApple(idToken: String, nonce: String) async throws -> Session {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let newSession = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        session = newSession
        return newSession
    }

    func loadProfile() async {
        guard let userId = session?.user.id else { return }
        do {
            let fetched: Profile = try await client
                .from("profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            profile = fetched
        } catch {
            // No profile yet is acceptable; only surface real errors.
            if (error as? PostgrestError)?.code != "PGRST116" { // row not found
                errorMessage = error.localizedDescription
            }
        }
    }

    func upsertProfile(
        quitAt: Date,
        cigarettesPerDay: Int,
        pricePerPack: Double,
        currency: String? = "USD"
    ) async throws {
        guard let userId = session?.user.id else {
            throw AuthError.notAuthenticated
        }

        let payload = ProfileInsert(
            userId: userId,
            quitAt: quitAt,
            cigarettesPerDay: cigarettesPerDay,
            pricePerPack: pricePerPack,
            currency: currency
        )

        let inserted: Profile = try await client
            .from("profiles")
            .upsert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value

        profile = inserted
    }
}

struct ProfileInsert: Encodable {
    let userId: UUID
    let quitAt: Date
    let cigarettesPerDay: Int
    let pricePerPack: Double
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case quitAt = "quit_at"
        case cigarettesPerDay = "cigarettes_per_day"
        case pricePerPack = "price_per_pack"
        case currency
    }
}

enum AuthError: Error {
    case notAuthenticated
}

