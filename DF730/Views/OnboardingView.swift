//
//  OnboardingView.swift
//  SwipeQuest
//
//  Created by IGOR on 03/11/2025.
//

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Binding var isPresented: Bool
    
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(primaryColor)
                    .padding()
                }
                
                // Content
                TabView(selection: $currentPage) {
                    WelcomeScreen()
                        .tag(0)
                    
                    TutorialScreen1()
                        .tag(1)
                    
                    TutorialScreen2()
                        .tag(2)
                    
                    TutorialScreen3()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Continue button
                Button(action: {
                    if currentPage < 3 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage == 3 ? "Get Started" : "Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(primaryColor)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        isPresented = false
    }
}

// MARK: - Welcome Screen

struct WelcomeScreen: View {
    private let primaryColor = Color(hex: "#223656")
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 60))
                    .foregroundColor(primaryColor)
            }
            .padding(.bottom, 20)
            
            // Title
            Text("Welcome!")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            // Description
            Text("Connect dots with strategic swipes\nto solve unique puzzles")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            Spacer()
        }
    }
}

// MARK: - Tutorial Screen 1

struct TutorialScreen1: View {
    private let primaryColor = Color(hex: "#223656")
    @State private var animateDots = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animation
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 50, height: 50)
                        .offset(x: CGFloat(index - 1) * 80)
                        .scaleEffect(animateDots ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animateDots
                        )
                }
                
                // Connection line
                Path { path in
                    path.move(to: CGPoint(x: -80, y: 0))
                    path.addLine(to: CGPoint(x: 80, y: 0))
                }
                .stroke(primaryColor, lineWidth: 4)
            }
            .frame(height: 100)
            .padding(.vertical, 40)
            .onAppear {
                animateDots = true
            }
            
            // Title
            Text("Connect the Dots")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            // Description
            Text("Swipe to connect dots of the same color. Create paths by dragging your finger across adjacent dots.")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Tutorial Screen 2

struct TutorialScreen2: View {
    private let primaryColor = Color(hex: "#223656")
    @State private var progress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animation
            ZStack {
                // Target circle
                Circle()
                    .stroke(primaryColor.opacity(0.3), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(primaryColor, lineWidth: 8)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(primaryColor)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(primaryColor)
                }
            }
            .padding(.vertical, 40)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    progress = 1.0
                }
            }
            
            // Title
            Text("Complete Levels")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            // Description
            Text("Make the required number of connections to complete each level. Earn points and unlock new challenges!")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Tutorial Screen 3

struct TutorialScreen3: View {
    private let primaryColor = Color(hex: "#223656")
    @State private var showBadges = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Badges animation
            HStack(spacing: 20) {
                ForEach(["star.fill", "trophy.fill", "crown.fill"], id: \.self) { icon in
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: icon)
                            .font(.system(size: 36))
                            .foregroundColor(primaryColor)
                    }
                    .scaleEffect(showBadges ? 1.0 : 0.1)
                    .opacity(showBadges ? 1 : 0)
                }
            }
            .padding(.vertical, 40)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showBadges = true
                }
            }
            
            // Title
            Text("Earn Achievements")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
            
            // Description
            Text("Unlock achievements, climb the leaderboard, and discover beautiful themes as you progress through the game.")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

