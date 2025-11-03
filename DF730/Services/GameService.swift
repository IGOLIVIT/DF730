//
//  GameService.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation
import Combine

// MARK: - Game Service

class GameService: ObservableObject {
    @Published var gameState: GameState
    
    private let userDefaultsKey = "swipeQuest_gameState"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            self.gameState = decoded
        } else {
            self.gameState = .default
        }
        
        // Check if daily challenge should reset
        checkDailyChallenge()
    }
    
    func saveGameState() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func updateScore(_ points: Int) {
        gameState.score += points
        if gameState.score > gameState.highScore {
            gameState.highScore = gameState.score
        }
        saveGameState()
    }
    
    func completeLevel(_ level: Int, stars: Int = 1) {
        gameState.completedLevels.insert(level)
        if level >= gameState.currentLevel {
            gameState.currentLevel = level + 1
        }
        
        // Save stars for level
        if stars > (gameState.starsEarned[level] ?? 0) {
            gameState.starsEarned[level] = stars
        }
        
        gameState.totalGamesPlayed += 1
        saveGameState()
    }
    
    func unlockTheme(_ themeId: String) {
        if !gameState.unlockedThemes.contains(themeId) {
            gameState.unlockedThemes.append(themeId)
            saveGameState()
        }
    }
    
    func setDifficulty(_ difficulty: GameDifficulty) {
        gameState.difficulty = difficulty
        saveGameState()
    }
    
    func completeDailyChallenge() {
        gameState.dailyChallengeCompleted = true
        gameState.dailyChallengeDate = Date()
        saveGameState()
    }
    
    func updateBestStreak(_ streak: Int) {
        if streak > gameState.bestStreak {
            gameState.bestStreak = streak
            saveGameState()
        }
    }
    
    private func checkDailyChallenge() {
        guard let lastDate = gameState.dailyChallengeDate else {
            gameState.dailyChallengeCompleted = false
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        
        if today > lastDay {
            gameState.dailyChallengeCompleted = false
            saveGameState()
        }
    }
    
    func resetGame() {
        gameState = .default
        saveGameState()
    }
    
    func resetCurrentScore() {
        gameState.score = 0
        saveGameState()
    }
    
    func getTotalStars() -> Int {
        return gameState.starsEarned.values.reduce(0, +)
    }
}

