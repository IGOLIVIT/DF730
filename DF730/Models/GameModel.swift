//
//  GameModel.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Game Models

enum GameDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case expert = "Expert"
    case master = "Master"
    
    var description: String {
        switch self {
        case .easy: return "Relaxed gameplay"
        case .normal: return "Balanced challenge"
        case .hard: return "Intense puzzles"
        case .expert: return "For experts only"
        case .master: return "Ultimate challenge"
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .normal: return "star.fill"
        case .hard: return "flame.fill"
        case .expert: return "bolt.fill"
        case .master: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "#4CAF50"
        case .normal: return "#2196F3"
        case .hard: return "#FF9800"
        case .expert: return "#F44336"
        case .master: return "#9C27B0"
        }
    }
    
    var requiredLevel: Int {
        switch self {
        case .easy: return 1
        case .normal: return 1
        case .hard: return 10
        case .expert: return 25
        case .master: return 50
        }
    }
}

struct GameState: Codable {
    var currentLevel: Int
    var score: Int
    var highScore: Int
    var unlockedThemes: [String]
    var completedLevels: Set<Int>
    var difficulty: GameDifficulty
    var totalGamesPlayed: Int
    var bestStreak: Int
    var dailyChallengeCompleted: Bool
    var dailyChallengeDate: Date?
    var starsEarned: [Int: Int] // level: stars (1-3)
    
    static let `default` = GameState(
        currentLevel: 1,
        score: 0,
        highScore: 0,
        unlockedThemes: ["default"],
        completedLevels: [],
        difficulty: .normal,
        totalGamesPlayed: 0,
        bestStreak: 0,
        dailyChallengeCompleted: false,
        dailyChallengeDate: nil,
        starsEarned: [:]
    )
}

struct DotNode: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var color: Color
    var colorIndex: Int
    var isConnected: Bool
    var connections: [UUID]
    
    init(position: CGPoint, color: Color, colorIndex: Int) {
        self.id = UUID()
        self.position = position
        self.color = color
        self.colorIndex = colorIndex
        self.isConnected = false
        self.connections = []
    }
}

enum LevelType {
    case normal
    case timed
    case limited // limited moves
    case survival // chain reactions
    case puzzle // specific pattern
}

struct GameLevel {
    let levelNumber: Int
    let gridSize: Int
    let requiredConnections: Int
    let timeLimit: Int?
    let targetScore: Int
    let dotColors: [Color]
    let levelType: LevelType
    let maxMoves: Int?
    let bonusMultiplier: Double
    
    var dots: [DotNode] {
        generateDots()
    }
    
    private func generateDots() -> [DotNode] {
        var dots: [DotNode] = []
        let spacing: CGFloat = 60
        let offsetX: CGFloat = 40
        let offsetY: CGFloat = 150
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let x = offsetX + CGFloat(col) * spacing
                let y = offsetY + CGFloat(row) * spacing
                let colorIndex = Int.random(in: 0..<dotColors.count)
                let color = dotColors[colorIndex]
                dots.append(DotNode(position: CGPoint(x: x, y: y), color: color, colorIndex: colorIndex))
            }
        }
        
        return dots
    }
}

// MARK: - Level Generator

struct LevelGenerator {
    static func generateLevel(number: Int, difficulty: GameDifficulty = .normal) -> GameLevel {
        let baseColors: [Color] = [
            Color(hex: "#223656"),
            Color(hex: "#4A6FA5"),
            Color(hex: "#7FB3D5"),
            Color(hex: "#96C5F7"),
            Color(hex: "#E74C3C"),
            Color(hex: "#9B59B6"),
            Color(hex: "#F39C12"),
            Color(hex: "#27AE60")
        ]
        
        // Difficulty modifiers
        let difficultyModifier: (grid: Int, time: Int, connections: Int, colors: Int) = {
            switch difficulty {
            case .easy:
                return (grid: 0, time: 30, connections: -1, colors: -1)
            case .normal:
                return (grid: 0, time: 0, connections: 0, colors: 0)
            case .hard:
                return (grid: 1, time: -15, connections: 1, colors: 1)
            case .expert:
                return (grid: 1, time: -25, connections: 2, colors: 2)
            case .master:
                return (grid: 2, time: -30, connections: 3, colors: 2)
            }
        }()
        
        // Progressive difficulty with level tiers
        let tier = (number - 1) / 10
        
        // Grid size: 3x3 -> 7x7
        let baseGridSize = min(3 + tier, 6)
        let gridSize = min(baseGridSize + difficultyModifier.grid, 7)
        
        // Required connections
        let baseConnections = 3 + (number - 1) / 3
        let requiredConnections = max(3, baseConnections + difficultyModifier.connections)
        
        // Time limit (appears after level 5)
        var timeLimit: Int? = nil
        if number > 5 {
            let baseTime = max(60 - (number - 5) * 2, 30)
            timeLimit = max(baseTime + difficultyModifier.time, 15)
        }
        
        // Level type based on level number
        let levelType: LevelType = {
            let mod = number % 10
            if mod == 0 { return .survival }
            if mod == 5 { return .puzzle }
            if number > 10 && mod % 3 == 0 { return .timed }
            if number > 15 && mod % 4 == 0 { return .limited }
            return .normal
        }()
        
        // Max moves for limited levels
        var maxMoves: Int? = nil
        if levelType == .limited {
            maxMoves = requiredConnections + 2
        }
        
        // Target score
        let targetScore = 100 * number * (tier + 1)
        
        // Color count
        let baseColorCount = min(2 + tier / 2, baseColors.count)
        let colorCount = min(baseColorCount + difficultyModifier.colors, baseColors.count)
        let levelColors = Array(baseColors.prefix(colorCount))
        
        // Bonus multiplier
        let bonusMultiplier = 1.0 + (Double(tier) * 0.1) + difficultyBonus(difficulty)
        
        return GameLevel(
            levelNumber: number,
            gridSize: gridSize,
            requiredConnections: requiredConnections,
            timeLimit: timeLimit,
            targetScore: targetScore,
            dotColors: levelColors,
            levelType: levelType,
            maxMoves: maxMoves,
            bonusMultiplier: bonusMultiplier
        )
    }
    
    private static func difficultyBonus(_ difficulty: GameDifficulty) -> Double {
        switch difficulty {
        case .easy: return 0.0
        case .normal: return 0.2
        case .hard: return 0.5
        case .expert: return 1.0
        case .master: return 2.0
        }
    }
    
    // Generate daily challenge
    static func generateDailyChallenge() -> GameLevel {
        let today = Calendar.current.startOfDay(for: Date())
        let seed = today.timeIntervalSince1970
        
        // Use seed for consistent daily challenge
        let dayNumber = Int(seed / 86400)
        let level = (dayNumber % 20) + 1
        
        return generateLevel(number: level, difficulty: .hard)
    }
    
    // Generate infinite mode level
    static func generateInfiniteLevel(streak: Int) -> GameLevel {
        let progressiveLevel = min(streak / 3, 50) + 1
        let difficulty: GameDifficulty = {
            if streak < 10 { return .normal }
            if streak < 25 { return .hard }
            if streak < 50 { return .expert }
            return .master
        }()
        
        return generateLevel(number: progressiveLevel, difficulty: difficulty)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

