//
//  SettingsView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @State private var showResetConfirmation = false
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Settings
                        settingsSection(title: "Audio") {
                            SettingsToggle(
                                title: "Sound Effects",
                                icon: "speaker.wave.2.fill",
                                isOn: $soundEnabled
                            )
                            
                            SettingsToggle(
                                title: "Music",
                                icon: "music.note",
                                isOn: $musicEnabled
                            )
                        }
                        
                        // Haptics
                        settingsSection(title: "Haptics") {
                            SettingsToggle(
                                title: "Vibration",
                                icon: "iphone.radiowaves.left.and.right",
                                isOn: $hapticEnabled
                            )
                        }
                        
                        // Game Data
                        settingsSection(title: "Game Data") {
                            Button(action: { showResetConfirmation = true }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                        .frame(width: 32)
                                    
                                    Text("Reset Game Data")
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
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
        .alert("Reset Game Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetGameData()
            }
        } message: {
            Text("This will delete all your progress, scores, and achievements. This action cannot be undone.")
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func resetGameData() {
        UserDefaults.standard.removeObject(forKey: "swipeQuest_gameState")
        UserDefaults.standard.removeObject(forKey: "swipeQuest_achievements")
        UserDefaults.standard.removeObject(forKey: "swipeQuest_leaderboard")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Settings Toggle

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(primaryColor)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    SettingsView()
}

