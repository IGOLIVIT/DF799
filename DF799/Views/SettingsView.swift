//
//  SettingsView.swift
//  DF799
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            SettingsBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Statistics summary
                    statisticsSummarySection
                    
                    // Detailed stats
                    detailedStatsSection
                    
                    // Actions
                    actionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            // Reset success overlay
            if showResetSuccess {
                resetSuccessOverlay
            }
        }
        .alert("Reset All Progress", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("This will permanently delete all your progress, statistics, and earned badges. This action cannot be undone.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("View your statistics and manage data")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 10)
    }
    
    // MARK: - Statistics Summary
    private var statisticsSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryYellow)
                
                Text("Statistics Overview")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Main stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SummaryStatCard(
                    value: "\(gameManager.statistics.totalSessions)",
                    label: "Total Sessions",
                    icon: "gamecontroller.fill",
                    color: .accentOrange
                )
                
                SummaryStatCard(
                    value: "\(gameManager.statistics.completedLevels)",
                    label: "Levels Completed",
                    icon: "checkmark.circle.fill",
                    color: .deepGreen
                )
                
                SummaryStatCard(
                    value: String(format: "%.1f%%", gameManager.statistics.averageAccuracy),
                    label: "Average Accuracy",
                    icon: "target",
                    color: .blue
                )
                
                SummaryStatCard(
                    value: "\(gameManager.getUnlockedBadges().count)/\(gameManager.badges.count)",
                    label: "Badges Earned",
                    icon: "rosette",
                    color: .purple
                )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Detailed Stats
    private var detailedStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentOrange)
                
                Text("Detailed Statistics")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                DetailRow(label: "Total Play Sessions", value: "\(gameManager.statistics.totalSessions)")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Levels Completed", value: "\(gameManager.statistics.completedLevels)")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Current Winning Streak", value: "\(gameManager.statistics.currentStreak)")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Best Winning Streak", value: "\(gameManager.statistics.bestStreak)")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Average Accuracy", value: String(format: "%.2f%%", gameManager.statistics.averageAccuracy))
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Path Tiles Completed", value: "\(gameManager.getCompletedLevelsCount(for: .pathTiles))")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Rhythm Steps Completed", value: "\(gameManager.getCompletedLevelsCount(for: .rhythmSteps))")
                Divider().background(Color.white.opacity(0.1))
                
                DetailRow(label: "Badges Unlocked", value: "\(gameManager.getUnlockedBadges().count) of \(gameManager.badges.count)")
                
                if let lastPlayed = gameManager.statistics.lastPlayedDate {
                    Divider().background(Color.white.opacity(0.1))
                    DetailRow(label: "Last Played", value: formatDate(lastPlayed))
                }
            }
            .padding(.vertical, 4)
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gear")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Data Management")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Button(action: {
                showResetConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Reset All Progress")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .foregroundColor(.red)
                .padding(16)
                .background(Color.red.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Text("This will delete all your progress, statistics, and earned badges permanently.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Reset Success Overlay
    private var resetSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.deepGreen.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.deepGreen)
                }
                
                Text("Progress Reset")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("All data has been cleared")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
            )
        }
        .transition(.opacity)
    }
    
    // MARK: - Helper Methods
    private func performReset() {
        gameManager.resetAllProgress()
        
        withAnimation {
            showResetSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showResetSuccess = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Summary Stat Card
struct SummaryStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Settings Background
struct SettingsBackground: View {
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
                    .fill(Color.primaryYellow.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -80, y: 100)
                
                Circle()
                    .fill(Color.accentOrange.opacity(0.05))
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                    .offset(x: geometry.size.width - 80, y: geometry.size.height - 300)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SettingsView(gameManager: GameManager.shared)
}

