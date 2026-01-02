import Foundation
import SwiftUI

// MARK: - Local Mission (defined in app)

struct LocalMission: Identifiable {
    let id: String  // stable identifier like "first-coffee"
    let title: String
    let description: String
    let category: MissionCategory
    let icon: String
}

enum MissionCategory: String, CaseIterable, Identifiable {
    case morningWins = "Morning Wins"
    case socialVictories = "Social Victories"
    case dailyLife = "Daily Life"
    case emotionalStrength = "Emotional Strength"
    case celebrations = "Celebrations"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .morningWins: return "sunrise.fill"
        case .socialVictories: return "person.3.fill"
        case .dailyLife: return "calendar"
        case .emotionalStrength: return "brain.head.profile"
        case .celebrations: return "party.popper.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morningWins: return .orange
        case .socialVictories: return .pink
        case .dailyLife: return .blue
        case .emotionalStrength: return .purple
        case .celebrations: return .green
        }
    }
}

// MARK: - Local Mission Progress (stored in Supabase)

struct LocalMissionProgress: Codable, Identifiable {
    let id: UUID
    let missionId: String  // references LocalMission.id
    let userId: UUID
    let completedAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case missionId = "mission_id"
        case userId = "user_id"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
}

// MARK: - Database Mission (legacy, from Supabase)

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

