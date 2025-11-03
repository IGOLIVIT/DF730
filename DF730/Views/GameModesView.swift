//
//  GameModesView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Game Modes View

struct GameModesView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var achievementService: AchievementService
    @Environment(\.dismiss) private var dismiss
    
    @State private var showGame = false
    @State private var selectedMode: GameMode = .campaign
    @State private var selectedLevel: Int = 1
    @State private var selectedDifficulty: GameDifficulty?
    
    private let primaryColor = Color(hex: "#223656")
    
    enum GameMode {
        case campaign
        case dailyChallenge
        case infiniteMode
        case practice
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Difficulty selector
                        difficultySection
                        
                        // Game modes
                        modeSection
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            NavigationView {
                gameView
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(primaryColor)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("Game Modes")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - Difficulty Section
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Difficulty")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: (selectedDifficulty ?? gameService.gameState.difficulty) == difficulty,
                            isUnlocked: gameService.gameState.currentLevel >= difficulty.requiredLevel,
                            currentLevel: gameService.gameState.currentLevel,
                            action: {
                                if gameService.gameState.currentLevel >= difficulty.requiredLevel {
                                    selectedDifficulty = difficulty
                                    gameService.setDifficulty(difficulty)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Mode Section
    
    private var modeSection: some View {
        VStack(spacing: 12) {
            // Campaign Mode
            ModeCard(
                icon: "flag.fill",
                title: "Campaign",
                subtitle: "Progress through \(gameService.gameState.currentLevel) levels",
                color: primaryColor,
                badge: nil,
                action: {
                    selectedMode = .campaign
                    selectedLevel = gameService.gameState.currentLevel
                    showGame = true
                }
            )
            
            // Daily Challenge
            ModeCard(
                icon: "calendar.badge.clock",
                title: "Daily Challenge",
                subtitle: "New challenge every day",
                color: Color(hex: "#F39C12"),
                badge: gameService.gameState.dailyChallengeCompleted ? "✓ Completed" : "Available",
                action: {
                    selectedMode = .dailyChallenge
                    selectedLevel = 1
                    showGame = true
                }
            )
            
            // Infinite Mode
            ModeCard(
                icon: "infinity",
                title: "Infinite Mode",
                subtitle: "Best streak: \(gameService.gameState.bestStreak)",
                color: Color(hex: "#9B59B6"),
                badge: nil,
                action: {
                    selectedMode = .infiniteMode
                    selectedLevel = 1
                    showGame = true
                }
            )
            
            // Practice Mode
            ModeCard(
                icon: "book.fill",
                title: "Practice",
                subtitle: "Replay any completed level",
                color: Color(hex: "#27AE60"),
                badge: "\(gameService.gameState.completedLevels.count) completed",
                action: {
                    selectedMode = .practice
                    selectedLevel = max(1, gameService.gameState.currentLevel - 1)
                    showGame = true
                }
            )
        }
    }
    
    // MARK: - Game View
    
    @ViewBuilder
    private var gameView: some View {
        switch selectedMode {
        case .campaign:
            GameView(
                level: selectedLevel,
                gameService: gameService,
                achievementService: achievementService,
                difficulty: selectedDifficulty
            )
        case .dailyChallenge:
            DailyChallengeGameView(
                gameService: gameService,
                achievementService: achievementService
            )
        case .infiniteMode:
            InfiniteGameView(
                gameService: gameService,
                achievementService: achievementService
            )
        case .practice:
            GameView(
                level: selectedLevel,
                gameService: gameService,
                achievementService: achievementService,
                difficulty: selectedDifficulty
            )
        }
    }
}

// MARK: - Difficulty Card

struct DifficultyCard: View {
    let difficulty: GameDifficulty
    let isSelected: Bool
    let isUnlocked: Bool
    let currentLevel: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? Color(hex: difficulty.color)
                            : Color(hex: difficulty.color).opacity(0.2)
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .white : Color(hex: difficulty.color))
                }
                
                Text(difficulty.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(difficulty.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Lvl \(difficulty.requiredLevel)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.gray)
                }
            }
            .frame(width: 100)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? Color(hex: difficulty.color) : Color.clear,
                        lineWidth: 2
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

// MARK: - Mode Card

struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

// MARK: - Daily Challenge Game View

struct DailyChallengeGameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(gameService: GameService, achievementService: AchievementService) {
        let dailyLevel = LevelGenerator.generateDailyChallenge()
        _viewModel = StateObject(wrappedValue: GameViewModel(
            levelNumber: dailyLevel.levelNumber,
            gameService: gameService,
            achievementService: achievementService,
            difficulty: .hard
        ))
    }
    
    var body: some View {
        GameView(
            level: viewModel.currentLevel.levelNumber,
            gameService: viewModel.gameService,
            achievementService: viewModel.achievementService,
            difficulty: .hard
        )
    }
}

// MARK: - Infinite Game View

struct InfiniteGameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var streak = 0
    
    init(gameService: GameService, achievementService: AchievementService) {
        let infiniteLevel = LevelGenerator.generateInfiniteLevel(streak: 0)
        _viewModel = StateObject(wrappedValue: GameViewModel(
            levelNumber: infiniteLevel.levelNumber,
            gameService: gameService,
            achievementService: achievementService,
            difficulty: .normal
        ))
    }
    
    var body: some View {
        GameView(
            level: viewModel.currentLevel.levelNumber,
            gameService: viewModel.gameService,
            achievementService: viewModel.achievementService,
            difficulty: .normal
        )
    }
}

#Preview {
    GameModesView()
        .environmentObject(GameService())
        .environmentObject(AchievementService())
}


