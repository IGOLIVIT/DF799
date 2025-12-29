//
//  HomeView.swift
//  DF799
//

import SwiftUI

// MARK: - Game Launch Configuration
struct GameLaunchConfig: Identifiable {
    let id = UUID()
    let gameType: GameType
    let difficulty: Difficulty
}

struct HomeView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedTab: Int
    
    @State private var activeGame: GameLaunchConfig?
    @State private var pathTilesDifficulty: Difficulty = .medium
    @State private var rhythmStepsDifficulty: Difficulty = .medium
    @State private var cardsAppeared = false
    
    private let motivationalSubtitles = [
        "Every step brings you closer to your goals",
        "Challenge yourself, grow stronger",
        "Focus, play, achieve",
        "Your journey of progress awaits"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                HomeBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                            .padding(.top, 10)
                        
                        // Quick stats
                        quickStatsBar
                        
                        // Game cards
                        gameCardsSection
                        
                        // Recent badges preview
                        if !gameManager.getUnlockedBadges().isEmpty {
                            recentBadgesSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $activeGame) { config in
                switch config.gameType {
                case .pathTiles:
                    PathTilesGameView(
                        gameManager: gameManager,
                        difficulty: config.difficulty,
                        onDismiss: { activeGame = nil }
                    )
                    .id(config.id) // Force fresh view creation
                case .rhythmSteps:
                    RhythmStepsGameView(
                        gameManager: gameManager,
                        difficulty: config.difficulty,
                        onDismiss: { activeGame = nil }
                    )
                    .id(config.id) // Force fresh view creation
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                cardsAppeared = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(motivationalSubtitles.randomElement() ?? motivationalSubtitles[0])
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Choose Your Challenge")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Quick Stats Bar
    private var quickStatsBar: some View {
        HStack(spacing: 15) {
            StatPill(
                icon: "flame.fill",
                value: "\(gameManager.statistics.currentStreak)",
                label: "Streak",
                color: .accentOrange
            )
            
            StatPill(
                icon: "checkmark.circle.fill",
                value: "\(gameManager.statistics.completedLevels)",
                label: "Completed",
                color: .deepGreen
            )
            
            StatPill(
                icon: "rosette",
                value: "\(gameManager.getUnlockedBadges().count)",
                label: "Badges",
                color: .primaryYellow
            )
        }
    }
    
    // MARK: - Game Cards Section
    private var gameCardsSection: some View {
        VStack(spacing: 20) {
            GameCard(
                gameType: .pathTiles,
                completedLevels: gameManager.getCompletedLevelsCount(for: .pathTiles),
                selectedDifficulty: $pathTilesDifficulty,
                isAppeared: cardsAppeared,
                delay: 0
            ) {
                activeGame = GameLaunchConfig(gameType: .pathTiles, difficulty: pathTilesDifficulty)
            }
            
            GameCard(
                gameType: .rhythmSteps,
                completedLevels: gameManager.getCompletedLevelsCount(for: .rhythmSteps),
                selectedDifficulty: $rhythmStepsDifficulty,
                isAppeared: cardsAppeared,
                delay: 0.1
            ) {
                activeGame = GameLaunchConfig(gameType: .rhythmSteps, difficulty: rhythmStepsDifficulty)
            }
        }
    }
    
    // MARK: - Recent Badges Section
    private var recentBadgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Badges")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { selectedTab = 1 }) {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.primaryYellow)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(gameManager.getUnlockedBadges().suffix(4)) { badge in
                        MinisBadgeCard(badge: badge)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Game Card
struct GameCard: View {
    let gameType: GameType
    let completedLevels: Int
    @Binding var selectedDifficulty: Difficulty
    let isAppeared: Bool
    let delay: Double
    let onPlay: () -> Void
    
    @State private var isPressed = false
    @State private var showDifficultyPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(alignment: .leading, spacing: 16) {
                // Icon and title row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentOrange, Color.primaryYellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: gameType.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color.deepGreen)
                        
                        Text("\(completedLevels) levels completed")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(gameType.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
                
                // Difficulty selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.8))
                        .textCase(.uppercase)
                    
                    HStack(spacing: 10) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyButton(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                }
                
                // Play button
                Button(action: onPlay) {
                    HStack {
                        Text("Play")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient.warmGradient
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.2), value: isPressed)
            }
            .padding(20)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 8)
        .scaleEffect(isAppeared ? 1.0 : 0.9)
        .opacity(isAppeared ? 1.0 : 0)
        .animation(.spring(response: 0.5).delay(delay), value: isAppeared)
    }
}

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    private var buttonColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(difficulty.rawValue)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : buttonColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? buttonColor : buttonColor.opacity(0.15))
                )
        }
    }
}

// MARK: - Mini Badge Card
struct MinisBadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryYellow, Color.accentOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(badge.name)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Home Background
struct HomeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.deepGreen,
                    Color.deepGreen.opacity(0.95),
                    Color.deepGreen.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Decorative shapes
            GeometryReader { geometry in
                // Top right circle
                Circle()
                    .fill(Color.primaryYellow.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: geometry.size.width - 100, y: -50)
                
                // Bottom left circle
                Circle()
                    .fill(Color.accentOrange.opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: -80, y: geometry.size.height - 200)
                
                // Center accent
                Circle()
                    .fill(Color.primaryYellow.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geometry.size.width / 2 - 150, y: geometry.size.height / 2)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView(gameManager: GameManager.shared, selectedTab: .constant(0))
}

