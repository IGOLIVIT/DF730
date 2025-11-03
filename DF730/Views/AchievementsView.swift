//
//  AchievementsView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Achievements View

struct AchievementsView: View {
    @StateObject private var viewModel: AchievementViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let primaryColor = Color(hex: "#223656")
    
    init(achievementService: AchievementService) {
        _viewModel = StateObject(wrappedValue: AchievementViewModel(achievementService: achievementService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overall Progress
                        progressCard
                        
                        // Unlocked Achievements
                        if !viewModel.unlockedAchievements.isEmpty {
                            achievementSection(
                                title: "Unlocked",
                                achievements: viewModel.unlockedAchievements,
                                isUnlocked: true
                            )
                        }
                        
                        // Locked Achievements
                        if !viewModel.lockedAchievements.isEmpty {
                            achievementSection(
                                title: "Locked",
                                achievements: viewModel.lockedAchievements,
                                isUnlocked: false
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            Text("Overall Progress")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            ZStack {
                Circle()
                    .stroke(primaryColor.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: viewModel.completionPercentage / 100)
                    .stroke(primaryColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: viewModel.completionPercentage)
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.completionPercentage))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(primaryColor)
                    
                    Text("\(viewModel.unlockedAchievements.count)/\(viewModel.achievements.count)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
    }
    
    // MARK: - Achievement Section
    
    private func achievementSection(title: String, achievements: [Achievement], isUnlocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementRow(achievement: achievement, isUnlocked: isUnlocked)
                }
            }
        }
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? primaryColor : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(achievement.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if !isUnlocked {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(primaryColor)
                                    .frame(width: geometry.size.width * achievement.progress, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(achievement.currentValue)/\(achievement.requiredValue)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // Checkmark or lock
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

#Preview {
    AchievementsView(achievementService: AchievementService())
}


