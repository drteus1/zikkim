import Foundation

enum MissionsData {
    static let missions: [LocalMission] = [
        // MARK: - Morning Wins
        LocalMission(
            id: "first-morning",
            title: "First Morning",
            description: "Wake up and start your day without reaching for a cigarette.",
            category: .morningWins,
            icon: "sunrise.fill"
        ),
        LocalMission(
            id: "first-coffee",
            title: "First Coffee",
            description: "Enjoy your morning coffee without the usual smoke.",
            category: .morningWins,
            icon: "cup.and.saucer.fill"
        ),
        LocalMission(
            id: "first-breakfast",
            title: "First Breakfast",
            description: "Complete your breakfast routine smoke-free.",
            category: .morningWins,
            icon: "fork.knife"
        ),
        
        // MARK: - Social Victories
        LocalMission(
            id: "first-friends-gathering",
            title: "Friends Gathering",
            description: "Hang out with friends without stepping away to smoke.",
            category: .socialVictories,
            icon: "person.3.fill"
        ),
        LocalMission(
            id: "first-party",
            title: "First Party",
            description: "Enjoy a party from start to finish without smoking.",
            category: .socialVictories,
            icon: "party.popper.fill"
        ),
        LocalMission(
            id: "first-date",
            title: "First Date",
            description: "Go on a date and stay present the whole time.",
            category: .socialVictories,
            icon: "heart.fill"
        ),
        LocalMission(
            id: "first-family-dinner",
            title: "Family Dinner",
            description: "Share a meal with family without excusing yourself to smoke.",
            category: .socialVictories,
            icon: "house.fill"
        ),
        
        // MARK: - Daily Life
        LocalMission(
            id: "first-work-break",
            title: "Work Break",
            description: "Take a break at work without reaching for cigarettes.",
            category: .dailyLife,
            icon: "briefcase.fill"
        ),
        LocalMission(
            id: "first-phone-call",
            title: "Long Phone Call",
            description: "Have a lengthy conversation without lighting up.",
            category: .dailyLife,
            icon: "phone.fill"
        ),
        LocalMission(
            id: "first-long-drive",
            title: "Long Drive",
            description: "Complete a road trip without smoking in the car.",
            category: .dailyLife,
            icon: "car.fill"
        ),
        LocalMission(
            id: "first-waiting-room",
            title: "Waiting Room",
            description: "Wait patiently at a doctor's office or similar without craving.",
            category: .dailyLife,
            icon: "clock.fill"
        ),
        LocalMission(
            id: "first-commute",
            title: "Daily Commute",
            description: "Complete your commute to work smoke-free.",
            category: .dailyLife,
            icon: "tram.fill"
        ),
        
        // MARK: - Emotional Strength
        LocalMission(
            id: "first-stress",
            title: "Stressful Moment",
            description: "Handle a stressful situation without using cigarettes to cope.",
            category: .emotionalStrength,
            icon: "bolt.heart.fill"
        ),
        LocalMission(
            id: "first-bad-news",
            title: "Bad News",
            description: "Process difficult news without reaching for a smoke.",
            category: .emotionalStrength,
            icon: "cloud.rain.fill"
        ),
        LocalMission(
            id: "first-argument",
            title: "After an Argument",
            description: "Cool down after a disagreement without smoking.",
            category: .emotionalStrength,
            icon: "bubble.left.and.bubble.right.fill"
        ),
        LocalMission(
            id: "first-boredom",
            title: "Boredom Buster",
            description: "Find something else to do when bored instead of smoking.",
            category: .emotionalStrength,
            icon: "sparkles"
        ),
        LocalMission(
            id: "first-anxiety",
            title: "Anxious Moment",
            description: "Manage anxiety without relying on cigarettes.",
            category: .emotionalStrength,
            icon: "waveform.path.ecg"
        ),
        
        // MARK: - Celebrations
        LocalMission(
            id: "first-celebration",
            title: "Celebration",
            description: "Celebrate good news or an achievement smoke-free.",
            category: .celebrations,
            icon: "star.fill"
        ),
        LocalMission(
            id: "first-drink",
            title: "First Drink",
            description: "Enjoy an alcoholic beverage without the cigarette pairing.",
            category: .celebrations,
            icon: "wineglass.fill"
        ),
        LocalMission(
            id: "first-concert",
            title: "Concert or Event",
            description: "Attend a live event without stepping out to smoke.",
            category: .celebrations,
            icon: "music.note.list"
        ),
        LocalMission(
            id: "first-weekend",
            title: "Full Weekend",
            description: "Complete an entire weekend without a single cigarette.",
            category: .celebrations,
            icon: "sun.max.fill"
        ),
        LocalMission(
            id: "first-vacation-day",
            title: "Vacation Day",
            description: "Enjoy a relaxing day off completely smoke-free.",
            category: .celebrations,
            icon: "beach.umbrella.fill"
        )
    ]
    
    static func missions(for category: MissionCategory) -> [LocalMission] {
        missions.filter { $0.category == category }
    }
}

