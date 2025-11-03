//
//  AchievementModel.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation

// MARK: - Achievement Models

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let requiredValue: Int
    var currentValue: Int
    var isUnlocked: Bool
    
    var progress: Double {
        return min(Double(currentValue) / Double(requiredValue), 1.0)
    }
}

// MARK: - Leaderboard Models

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let level: Int
    let date: Date
    
    init(playerName: String, score: Int, level: Int) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.level = level
        self.date = Date()
    }
}

// MARK: - Theme Models

struct GameTheme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let backgroundColor: String
    let requiredLevel: Int
    var isUnlocked: Bool
    
    static let allThemes: [GameTheme] = [
        GameTheme(
            id: "default",
            name: "Classic Blue",
            primaryColor: "#223656",
            secondaryColor: "#4A6FA5",
            backgroundColor: "#FFFFFF",
            requiredLevel: 1,
            isUnlocked: true
        ),
        GameTheme(
            id: "sunset",
            name: "Sunset Orange",
            primaryColor: "#FF6B35",
            secondaryColor: "#F7931E",
            backgroundColor: "#FFF5E6",
            requiredLevel: 5,
            isUnlocked: false
        ),
        GameTheme(
            id: "forest",
            name: "Forest Green",
            primaryColor: "#2D5016",
            secondaryColor: "#87A96B",
            backgroundColor: "#F0F8F0",
            requiredLevel: 10,
            isUnlocked: false
        ),
        GameTheme(
            id: "royal",
            name: "Royal Purple",
            primaryColor: "#5B2C6F",
            secondaryColor: "#A569BD",
            backgroundColor: "#F8F3FF",
            requiredLevel: 15,
            isUnlocked: false
        ),
        GameTheme(
            id: "ocean",
            name: "Deep Ocean",
            primaryColor: "#154360",
            secondaryColor: "#5DADE2",
            backgroundColor: "#EBF5FB",
            requiredLevel: 20,
            isUnlocked: false
        )
    ]
}

// MARK: - Achievement Definitions

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_win",
            title: "First Victory",
            description: "Complete your first level",
            iconName: "star.fill",
            requiredValue: 1,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "level_5",
            title: "Getting Started",
            description: "Reach level 5",
            iconName: "5.circle.fill",
            requiredValue: 5,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "level_10",
            title: "Halfway Hero",
            description: "Reach level 10",
            iconName: "10.circle.fill",
            requiredValue: 10,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "level_20",
            title: "Master Swiper",
            description: "Reach level 20",
            iconName: "20.circle.fill",
            requiredValue: 20,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "score_1000",
            title: "Score Hunter",
            description: "Earn 1000 total points",
            iconName: "target",
            requiredValue: 1000,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "score_5000",
            title: "Point Master",
            description: "Earn 5000 total points",
            iconName: "crown.fill",
            requiredValue: 5000,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "perfect_10",
            title: "Perfect Streak",
            description: "Complete 10 levels in a row",
            iconName: "flame.fill",
            requiredValue: 10,
            currentValue: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "all_themes",
            title: "Theme Collector",
            description: "Unlock all themes",
            iconName: "paintpalette.fill",
            requiredValue: 5,
            currentValue: 1,
            isUnlocked: false
        )
    ]
}


