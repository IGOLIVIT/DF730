//
//  GameViewModel.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game ViewModel

class GameViewModel: ObservableObject {
    @Published var currentLevel: GameLevel
    @Published var dots: [DotNode]
    @Published var connectedPath: [UUID] = []
    @Published var currentScore: Int = 0
    @Published var timeRemaining: Int?
    @Published var isLevelComplete: Bool = false
    @Published var showLevelComplete: Bool = false
    @Published var consecutiveWins: Int = 0
    @Published var movesRemaining: Int?
    @Published var starsEarned: Int = 0
    
    private var timer: Timer?
    let gameService: GameService
    let achievementService: AchievementService
    private let difficulty: GameDifficulty
    
    init(levelNumber: Int, gameService: GameService, achievementService: AchievementService, difficulty: GameDifficulty? = nil) {
        let useDifficulty = difficulty ?? gameService.gameState.difficulty
        let level = LevelGenerator.generateLevel(number: levelNumber, difficulty: useDifficulty)
        self.currentLevel = level
        self.dots = level.dots
        self.timeRemaining = level.timeLimit
        self.movesRemaining = level.maxMoves
        self.gameService = gameService
        self.achievementService = achievementService
        self.difficulty = useDifficulty
        
        if level.timeLimit != nil {
            startTimer()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let remaining = self.timeRemaining, remaining > 0 {
                self.timeRemaining = remaining - 1
            } else if self.timeRemaining == 0 {
                self.handleTimeUp()
            }
        }
    }
    
    private func handleTimeUp() {
        timer?.invalidate()
        // Game over logic
    }
    
    // MARK: - Game Logic
    
    func handleDotTapped(_ dotId: UUID) {
        if isLevelComplete { return }
        
        guard let dotIndex = dots.firstIndex(where: { $0.id == dotId }) else { return }
        
        // If path is empty, start new path
        if connectedPath.isEmpty {
            connectedPath.append(dotId)
            dots[dotIndex].isConnected = true
            return
        }
        
        // Check if tapping the same dot (ignore)
        if connectedPath.last == dotId {
            return
        }
        
        // Check if dot is already in path (but not last) - remove everything after it
        if let existingIndex = connectedPath.firstIndex(of: dotId), existingIndex < connectedPath.count - 1 {
            // Remove all dots after this one
            for i in (existingIndex + 1)..<connectedPath.count {
                if let idx = dots.firstIndex(where: { $0.id == connectedPath[i] }) {
                    dots[idx].isConnected = false
                }
            }
            connectedPath.removeSubrange((existingIndex + 1)...)
            return
        }
        
        // Check if dot is already in path
        if connectedPath.contains(dotId) {
            return
        }
        
        // Check if dot is adjacent to last dot in path
        if let lastDotId = connectedPath.last,
           let lastDotIndex = dots.firstIndex(where: { $0.id == lastDotId }),
           isAdjacent(dot1: dots[lastDotIndex], dot2: dots[dotIndex]) {
            
            // Check if colors match
            if dots[lastDotIndex].colorIndex == dots[dotIndex].colorIndex {
                connectedPath.append(dotId)
                dots[dotIndex].isConnected = true
            }
        }
    }
    
    func handleDragChanged(location: CGPoint) {
        if isLevelComplete { return }
        
        // Find dot at location
        for dot in dots {
            let distance = hypot(location.x - dot.position.x, location.y - dot.position.y)
            if distance < 30 { // Touch radius
                handleDotTapped(dot.id)
                break
            }
        }
    }
    
    func handleDragEnded() {
        // Check moves limit
        if let moves = movesRemaining {
            movesRemaining = moves - 1
            if moves - 1 < 0 {
                // Game over - no moves left
                clearPath()
                return
            }
        }
        
        // Automatically complete if we have enough connections
        if connectedPath.count >= currentLevel.requiredConnections {
            handleConnectionComplete()
        } else {
            // Clear path if not enough connections
            clearPath()
        }
    }
    
    private func isAdjacent(dot1: DotNode, dot2: DotNode) -> Bool {
        let dx = abs(dot1.position.x - dot2.position.x)
        let dy = abs(dot1.position.y - dot2.position.y)
        
        // Adjacent if distance is approximately one grid cell
        let gridSpacing: CGFloat = 60
        let tolerance: CGFloat = 5
        
        // Horizontal or vertical neighbor
        if (dx < tolerance && abs(dy - gridSpacing) < tolerance) ||
           (dy < tolerance && abs(dx - gridSpacing) < tolerance) {
            return true
        }
        
        // Diagonal neighbor
        if abs(dx - gridSpacing) < tolerance && abs(dy - gridSpacing) < tolerance {
            return true
        }
        
        return false
    }
    
    private func handleConnectionComplete() {
        let points = calculatePoints()
        currentScore += points
        
        // Calculate stars based on performance
        starsEarned = calculateStars()
        
        // Update game state
        gameService.updateScore(points)
        gameService.completeLevel(currentLevel.levelNumber, stars: starsEarned)
        
        consecutiveWins += 1
        gameService.updateBestStreak(consecutiveWins)
        
        // Check achievements
        achievementService.checkAndUnlockAchievements(
            level: currentLevel.levelNumber,
            totalScore: gameService.gameState.score,
            consecutiveWins: consecutiveWins
        )
        
        // Check for theme unlocks
        checkThemeUnlocks()
        
        isLevelComplete = true
        timer?.invalidate()
        
        // Show completion after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showLevelComplete = true
        }
    }
    
    private func calculatePoints() -> Int {
        let basePoints = connectedPath.count * 10
        let comboMultiplier = max(1, connectedPath.count - currentLevel.requiredConnections)
        let timeBonus = timeRemaining ?? 0
        let movesBonus = (movesRemaining ?? 0) * 5
        
        let totalPoints = Int(Double(basePoints * (1 + comboMultiplier) + timeBonus + movesBonus) * currentLevel.bonusMultiplier)
        return totalPoints
    }
    
    private func calculateStars() -> Int {
        let efficiency = Double(connectedPath.count) / Double(currentLevel.requiredConnections)
        let timeEfficiency: Double
        
        if let timeLimit = currentLevel.timeLimit, let remaining = timeRemaining {
            timeEfficiency = Double(remaining) / Double(timeLimit)
        } else {
            timeEfficiency = 1.0
        }
        
        let movesEfficiency: Double
        if let maxMoves = currentLevel.maxMoves, let remaining = movesRemaining {
            movesEfficiency = Double(remaining + 1) / Double(maxMoves)
        } else {
            movesEfficiency = 1.0
        }
        
        let totalScore = (efficiency + timeEfficiency + movesEfficiency) / 3.0
        
        if totalScore >= 0.8 {
            return 3
        } else if totalScore >= 0.5 {
            return 2
        } else {
            return 1
        }
    }
    
    private func checkThemeUnlocks() {
        for theme in GameTheme.allThemes {
            if !theme.isUnlocked && currentLevel.levelNumber >= theme.requiredLevel {
                gameService.unlockTheme(theme.id)
            }
        }
        
        achievementService.updateThemeAchievement(
            unlockedCount: gameService.gameState.unlockedThemes.count
        )
    }
    
    func clearPath() {
        for dotId in connectedPath {
            if let index = dots.firstIndex(where: { $0.id == dotId }) {
                dots[index].isConnected = false
            }
        }
        connectedPath.removeAll()
    }
    
    func resetLevel() {
        dots = currentLevel.dots
        connectedPath.removeAll()
        currentScore = 0
        isLevelComplete = false
        showLevelComplete = false
        timeRemaining = currentLevel.timeLimit
        movesRemaining = currentLevel.maxMoves
        starsEarned = 0
        
        if currentLevel.timeLimit != nil {
            startTimer()
        }
    }
    
    func loadNextLevel() {
        let nextLevelNumber = currentLevel.levelNumber + 1
        currentLevel = LevelGenerator.generateLevel(number: nextLevelNumber, difficulty: difficulty)
        resetLevel()
    }
}

