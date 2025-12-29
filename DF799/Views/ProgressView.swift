//
//  ProgressView.swift
//  DF799
//

import SwiftUI

struct ProgressView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedSection: ProgressSection = .badges
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            // Background
            ProgressBackground()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Section picker
                sectionPicker
                    .padding(.top, 10)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch selectedSection {
                        case .badges:
                            badgesSection
                        case .statistics:
                            statisticsSection
                        case .levels:
                            levelsSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Journey")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Track your progress and achievements")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Section Picker
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(ProgressSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedSection = section
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: section.icon)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(section.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedSection == section ? .primaryYellow : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedSection == section ?
                        Color.white.opacity(0.15) : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(spacing: 20) {
            // Unlocked badges
            if !gameManager.getUnlockedBadges().isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Earned Badges")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(gameManager.getUnlockedBadges().count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryYellow)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.primaryYellow.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 14) {
                        ForEach(gameManager.getUnlockedBadges()) { badge in
                            BadgeCard(badge: badge, isUnlocked: true)
                        }
                    }
                }
            }
            
            // Locked badges
            if !gameManager.getLockedBadges().isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Locked Badges")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(gameManager.getLockedBadges().count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 14) {
                        ForEach(gameManager.getLockedBadges()) { badge in
                            BadgeCard(badge: badge, isUnlocked: false)
                        }
                    }
                }
            }
            
            if gameManager.badges.isEmpty {
                emptyStateView(
                    icon: "rosette",
                    title: "No Badges Yet",
                    subtitle: "Complete challenges to earn badges"
                )
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            // Main stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                StatCard(
                    icon: "gamecontroller.fill",
                    title: "Total Sessions",
                    value: "\(gameManager.statistics.totalSessions)",
                    color: .accentOrange
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Levels Completed",
                    value: "\(gameManager.statistics.completedLevels)",
                    color: .deepGreen
                )
                
                StatCard(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(gameManager.statistics.currentStreak)",
                    color: .red
                )
                
                StatCard(
                    icon: "trophy.fill",
                    title: "Best Streak",
                    value: "\(gameManager.statistics.bestStreak)",
                    color: .primaryYellow
                )
                
                StatCard(
                    icon: "target",
                    title: "Avg. Accuracy",
                    value: String(format: "%.1f%%", gameManager.statistics.averageAccuracy),
                    color: .blue
                )
                
                StatCard(
                    icon: "rosette",
                    title: "Badges Earned",
                    value: "\(gameManager.getUnlockedBadges().count)",
                    color: .purple
                )
            }
            
            // Game-specific stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Game Progress")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                GameProgressCard(
                    gameType: .pathTiles,
                    completedLevels: gameManager.getCompletedLevelsCount(for: .pathTiles)
                )
                
                GameProgressCard(
                    gameType: .rhythmSteps,
                    completedLevels: gameManager.getCompletedLevelsCount(for: .rhythmSteps)
                )
            }
            
            // Last played
            if let lastPlayed = gameManager.statistics.lastPlayedDate {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Last played: \(lastPlayed, style: .relative) ago")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Levels Section
    private var levelsSection: some View {
        VStack(spacing: 20) {
            // Path Tiles levels
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.accentOrange)
                    
                    Text("Path Tiles")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyLevelRow(
                        difficulty: difficulty,
                        completedLevels: gameManager.getHighestCompletedLevel(for: .pathTiles, difficulty: difficulty),
                        maxLevels: 10
                    )
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Rhythm Steps levels
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 18))
                        .foregroundColor(.accentOrange)
                    
                    Text("Rhythm Steps")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyLevelRow(
                        difficulty: difficulty,
                        completedLevels: gameManager.getHighestCompletedLevel(for: .rhythmSteps, difficulty: difficulty),
                        maxLevels: 10
                    )
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Empty State
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            
            Text(subtitle)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Progress Section Enum
enum ProgressSection: String, CaseIterable {
    case badges = "Badges"
    case statistics = "Stats"
    case levels = "Levels"
    
    var icon: String {
        switch self {
        case .badges: return "rosette"
        case .statistics: return "chart.bar.fill"
        case .levels: return "list.bullet"
        }
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked ?
                        LinearGradient(
                            colors: [Color.primaryYellow, Color.accentOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))
            }
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                
                Text(badge.description)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            isUnlocked ?
            Color.white.opacity(0.12) :
            Color.white.opacity(0.05)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnlocked ? Color.primaryYellow.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Game Progress Card
struct GameProgressCard: View {
    let gameType: GameType
    let completedLevels: Int
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentOrange.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: gameType.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.accentOrange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(gameType.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentOrange, Color.primaryYellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(min(completedLevels, 30)) / 30)
                    }
                }
                .frame(height: 8)
            }
            
            Text("\(completedLevels)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryYellow)
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Difficulty Level Row
struct DifficultyLevelRow: View {
    let difficulty: Difficulty
    let completedLevels: Int
    let maxLevels: Int
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(difficulty.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(difficultyColor)
                .frame(width: 70, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(difficultyColor)
                        .frame(width: geometry.size.width * CGFloat(completedLevels) / CGFloat(maxLevels))
                }
            }
            .frame(height: 10)
            
            Text("\(completedLevels)/\(maxLevels)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 45, alignment: .trailing)
        }
    }
}

// MARK: - Progress Background
struct ProgressBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.deepGreen,
                    Color.deepGreen.opacity(0.95),
                    Color.deepGreen.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.primaryYellow.opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: geometry.size.width - 150, y: 50)
                
                Circle()
                    .fill(Color.accentOrange.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: -50, y: geometry.size.height - 250)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ProgressView(gameManager: GameManager.shared)
}

