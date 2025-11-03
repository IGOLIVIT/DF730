//
//  AchievementService.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation
import Combine

// MARK: - Achievement Service

class AchievementService: ObservableObject {
    @Published var achievements: [Achievement]
    @Published var leaderboard: [LeaderboardEntry]
    
    private let achievementsKey = "swipeQuest_achievements"
    private let leaderboardKey = "swipeQuest_leaderboard"
    
    init() {
        // Load achievements
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = decoded
        } else {
            self.achievements = Achievement.allAchievements
        }
        
        // Load leaderboard
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            self.leaderboard = decoded
        } else {
            self.leaderboard = []
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    func checkAndUnlockAchievements(level: Int, totalScore: Int, consecutiveWins: Int) {
        var hasChanges = false
        
        for index in achievements.indices {
            if achievements[index].isUnlocked {
                continue
            }
            
            switch achievements[index].id {
            case "first_win":
                achievements[index].currentValue = max(achievements[index].currentValue, 1)
            case "level_5", "level_10", "level_20":
                achievements[index].currentValue = level
            case "score_1000", "score_5000":
                achievements[index].currentValue = totalScore
            case "perfect_10":
                achievements[index].currentValue = consecutiveWins
            default:
                break
            }
            
            if achievements[index].currentValue >= achievements[index].requiredValue {
                achievements[index].isUnlocked = true
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveAchievements()
        }
    }
    
    func updateThemeAchievement(unlockedCount: Int) {
        if let index = achievements.firstIndex(where: { $0.id == "all_themes" }) {
            achievements[index].currentValue = unlockedCount
            if unlockedCount >= achievements[index].requiredValue {
                achievements[index].isUnlocked = true
            }
            saveAchievements()
        }
    }
    
    func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        leaderboard.append(entry)
        leaderboard.sort { $0.score > $1.score }
        if leaderboard.count > 100 {
            leaderboard = Array(leaderboard.prefix(100))
        }
        saveLeaderboard()
    }
    
    func resetAchievements() {
        achievements = Achievement.allAchievements
        saveAchievements()
    }
    
    func resetLeaderboard() {
        leaderboard = []
        saveLeaderboard()
    }
}

