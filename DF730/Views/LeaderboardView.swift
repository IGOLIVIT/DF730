//
//  LeaderboardView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Leaderboard View

struct LeaderboardView: View {
    @StateObject private var viewModel: AchievementViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let primaryColor = Color(hex: "#223656")
    
    init(achievementService: AchievementService) {
        _viewModel = StateObject(wrappedValue: AchievementViewModel(achievementService: achievementService))
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                if viewModel.leaderboard.isEmpty {
                    // Empty state
                    emptyState
                } else {
                    // Leaderboard list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refresh()
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
            
            Text("Leaderboard")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(primaryColor.opacity(0.3))
            
            Text("No Scores Yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            Text("Complete levels to appear\non the leaderboard!")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    private let primaryColor = Color(hex: "#223656")
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFD700") // Gold
        case 2: return Color(hex: "#C0C0C0") // Silver
        case 3: return Color(hex: "#CD7F32") // Bronze
        default: return primaryColor
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return "\(rank).circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.system(size: 24))
                        .foregroundColor(rankColor)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(rankColor)
                }
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("Level \(entry.level)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Score
            Text("\(entry.score)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    LeaderboardView(achievementService: AchievementService())
}


