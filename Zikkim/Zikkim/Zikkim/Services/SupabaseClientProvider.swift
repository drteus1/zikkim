import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://khkdwaezhwvhlfipwzju.supabase.co")!
    // Publishable/anon key only. Consider moving to keychain/env for production.
    static let anonKey = "sb_publishable_KKjOVejiQZuQfkWg8y5cDA_yEnEfBgi"
}

struct SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.anonKey)
    }
}

