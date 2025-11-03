//
//  GameView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Game View

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSettings = false
    
    private let primaryColor = Color(hex: "#223656")
    
    init(level: Int, gameService: GameService, achievementService: AchievementService, difficulty: GameDifficulty? = nil) {
        _viewModel = StateObject(wrappedValue: GameViewModel(
            levelNumber: level,
            gameService: gameService,
            achievementService: achievementService,
            difficulty: difficulty
        ))
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Game board
                GeometryReader { geometry in
                    ZStack {
                        // Connection lines
                        connectionLines
                        
                        // Dots
                        ForEach(viewModel.dots) { dot in
                            DotView(
                                dot: dot,
                                isInPath: viewModel.connectedPath.contains(dot.id)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                viewModel.handleDragChanged(location: value.location)
                            }
                            .onEnded { _ in
                                viewModel.handleDragEnded()
                            }
                    )
                }
                
                // Footer
                footer
            }
            
            // Level complete overlay
            if viewModel.showLevelComplete {
                LevelCompleteView(
                    score: viewModel.currentScore,
                    stars: viewModel.starsEarned,
                    onNextLevel: {
                        viewModel.loadNextLevel()
                    },
                    onMainMenu: {
                        dismiss()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("Level \(viewModel.currentLevel.levelNumber)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(primaryColor)
                    
                    // Level type indicator
                    if viewModel.currentLevel.levelType != .normal {
                        levelTypeBadge
                    }
                }
                
                Text("Score: \(viewModel.currentScore)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(primaryColor)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var levelTypeBadge: some View {
        let typeInfo: (text: String, color: Color) = {
            switch viewModel.currentLevel.levelType {
            case .timed:
                return ("⏱️", Color.orange)
            case .limited:
                return ("🎯", Color.red)
            case .survival:
                return ("⚡️", Color.purple)
            case .puzzle:
                return ("🧩", Color.blue)
            default:
                return ("", Color.clear)
            }
        }()
        
        if !typeInfo.text.isEmpty {
            Text(typeInfo.text)
                .font(.system(size: 12))
        }
    }
    
    // MARK: - Connection Lines
    
    private var connectionLines: some View {
        Canvas { context, size in
            guard viewModel.connectedPath.count > 1 else { return }
            
            var path = Path()
            
            for (index, dotId) in viewModel.connectedPath.enumerated() {
                if let dot = viewModel.dots.first(where: { $0.id == dotId }) {
                    if index == 0 {
                        path.move(to: dot.position)
                    } else {
                        path.addLine(to: dot.position)
                    }
                }
            }
            
            context.stroke(
                path,
                with: .color(primaryColor),
                lineWidth: 6
            )
        }
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        VStack(spacing: 12) {
            // Timer and moves in one row
            HStack(spacing: 16) {
                // Timer (if applicable)
                if let timeRemaining = viewModel.timeRemaining {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(timeRemaining < 10 ? .red : primaryColor)
                        Text("\(timeRemaining)s")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(timeRemaining < 10 ? .red : primaryColor)
                    }
                }
                
                // Moves (if applicable)
                if let movesRemaining = viewModel.movesRemaining {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(movesRemaining < 2 ? .red : primaryColor)
                        Text("\(movesRemaining) moves")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(movesRemaining < 2 ? .red : primaryColor)
                    }
                }
            }
            
            // Progress
            HStack(spacing: 8) {
                Text("Connections:")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("\(viewModel.connectedPath.count) / \(viewModel.currentLevel.requiredConnections)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(
                        viewModel.connectedPath.count >= viewModel.currentLevel.requiredConnections ? .green : primaryColor
                    )
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            viewModel.connectedPath.count >= viewModel.currentLevel.requiredConnections 
                            ? Color.green 
                            : primaryColor
                        )
                        .frame(
                            width: geometry.size.width * min(
                                CGFloat(viewModel.connectedPath.count) / CGFloat(viewModel.currentLevel.requiredConnections),
                                1.0
                            ),
                            height: 8
                        )
                        .animation(.spring(response: 0.3), value: viewModel.connectedPath.count)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 32)
            
            // Clear button
            Button(action: {
                viewModel.clearPath()
            }) {
                Text("Clear Path")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(primaryColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(primaryColor.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .disabled(viewModel.connectedPath.isEmpty)
            .opacity(viewModel.connectedPath.isEmpty ? 0.5 : 1.0)
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

// MARK: - Dot View

struct DotView: View {
    let dot: DotNode
    let isInPath: Bool
    
    var body: some View {
        Circle()
            .fill(dot.color)
            .frame(width: 44, height: 44)
            .overlay(
                Circle()
                    .strokeBorder(Color.white, lineWidth: isInPath ? 4 : 0)
            )
            .scaleEffect(isInPath ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isInPath)
            .shadow(color: dot.color.opacity(0.3), radius: isInPath ? 8 : 4)
            .position(dot.position)
    }
}

// MARK: - Level Complete View

struct LevelCompleteView: View {
    let score: Int
    let stars: Int
    let onNextLevel: () -> Void
    let onMainMenu: () -> Void
    
    private let primaryColor = Color(hex: "#223656")
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 24) {
                // Success icon with stars
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(primaryColor)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.1)
                    .rotationEffect(.degrees(showContent ? 0 : 180))
                    
                    // Stars earned
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { index in
                            Image(systemName: index <= stars ? "star.fill" : "star")
                                .font(.system(size: 24))
                                .foregroundColor(index <= stars ? .yellow : .gray.opacity(0.3))
                                .scaleEffect(showContent ? 1.0 : 0.1)
                                .animation(
                                    Animation.spring(response: 0.5, dampingFraction: 0.6)
                                        .delay(Double(index) * 0.1),
                                    value: showContent
                                )
                        }
                    }
                }
                
                // Title
                Text("Level Complete!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                    .opacity(showContent ? 1 : 0)
                
                // Score
                VStack(spacing: 8) {
                    Text("Score")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(primaryColor)
                }
                .opacity(showContent ? 1 : 0)
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: onNextLevel) {
                        Text("Next Level")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(primaryColor)
                            .cornerRadius(16)
                    }
                    
                    Button(action: onMainMenu) {
                        Text("Main Menu")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(primaryColor)
                    }
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

#Preview {
    GameView(
        level: 1,
        gameService: GameService(),
        achievementService: AchievementService()
    )
}

