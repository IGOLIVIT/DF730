//
//  ThemeSelectionView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Theme Selection View

struct ThemeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameService: GameService
    @AppStorage("selectedThemeId") private var selectedThemeId = "default"
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(GameTheme.allThemes) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: selectedThemeId == theme.id,
                                isUnlocked: gameService.gameState.unlockedThemes.contains(theme.id),
                                currentLevel: gameService.gameState.currentLevel,
                                onSelect: {
                                    if gameService.gameState.unlockedThemes.contains(theme.id) {
                                        selectedThemeId = theme.id
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Themes")
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
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: GameTheme
    let isSelected: Bool
    let isUnlocked: Bool
    let currentLevel: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Color preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: theme.backgroundColor))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: theme.primaryColor))
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .fill(Color(hex: theme.secondaryColor))
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Theme info
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    
                    if isUnlocked {
                        Text("Unlocked")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.green)
                    } else {
                        Text("Reach level \(theme.requiredLevel) to unlock")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: theme.primaryColor))
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color(hex: theme.primaryColor) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(GameService())
}


