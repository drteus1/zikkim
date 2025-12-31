import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let quitAt: Date
    let cigarettesPerDay: Int
    let pricePerPack: Double
    let currency: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quitAt = "quit_at"
        case cigarettesPerDay = "cigarettes_per_day"
        case pricePerPack = "price_per_pack"
        case currency
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

