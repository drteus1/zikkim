import Foundation

struct Craving: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let loggedAt: Date
    let intensity: Int?
    let triggerText: String?
    let note: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case loggedAt = "logged_at"
        case intensity
        case triggerText = "trigger_text"
        case note
        case createdAt = "created_at"
    }
}

