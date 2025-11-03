//
//  AchievementViewModel.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Achievement ViewModel

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement]
    @Published var leaderboard: [LeaderboardEntry]
    
    private let achievementService: AchievementService
    
    init(achievementService: AchievementService) {
        self.achievementService = achievementService
        self.achievements = achievementService.achievements
        self.leaderboard = achievementService.leaderboard
    }
    
    func refresh() {
        achievements = achievementService.achievements
        leaderboard = achievementService.leaderboard
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    var completionPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        return Double(unlockedCount) / Double(achievements.count) * 100
    }
}

