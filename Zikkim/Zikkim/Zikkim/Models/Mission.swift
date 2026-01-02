import Foundation

struct Mission: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let category: String?
    let sortOrder: Int?
    let reward: String?
    let active: Bool?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case sortOrder = "sort_order"
        case reward
        case active
        case createdAt = "created_at"
    }
}

struct MissionProgress: Codable, Identifiable {
    let id: UUID
    let missionId: UUID
    let userId: UUID
    let status: String
    let note: String?
    let completedAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case missionId = "mission_id"
        case userId = "user_id"
        case status
        case note
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
}

