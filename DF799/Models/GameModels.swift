//
//  GameModels.swift
//  DF799
//

import SwiftUI

// MARK: - Difficulty Enum
enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var timerMultiplier: Double {
        switch self {
        case .easy: return 1.5
        case .medium: return 1.0
        case .hard: return 0.7
        }
    }
    
    var scoreMultiplier: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

// MARK: - Game Type
enum GameType: String, Codable {
    case pathTiles = "Path Tiles"
    case rhythmSteps = "Rhythm Steps"
    
    var description: String {
        switch self {
        case .pathTiles:
            return "Tap tiles in the correct sequence before time runs out"
        case .rhythmSteps:
            return "Tap objects at precise timing to create perfect combos"
        }
    }
    
    var icon: String {
        switch self {
        case .pathTiles: return "square.grid.3x3.fill"
        case .rhythmSteps: return "waveform.path"
        }
    }
}

// MARK: - Badge Model
struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let requirement: BadgeRequirement
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.id == rhs.id
    }
}

struct BadgeRequirement: Codable {
    let type: RequirementType
    let value: Int
    let gameType: GameType?
    
    enum RequirementType: String, Codable {
        case completeLevels
        case achieveStreak
        case perfectAccuracy
        case completeHardMode
        case totalSessions
    }
}

// MARK: - Level Progress
struct LevelProgress: Codable {
    let gameType: GameType
    let difficulty: Difficulty
    let level: Int
    var bestScore: Int
    var completed: Bool
    var attempts: Int
    var bestAccuracy: Double
}

// MARK: - Game Session
struct GameSession: Codable {
    let id: UUID
    let gameType: GameType
    let difficulty: Difficulty
    let level: Int
    let score: Int
    let accuracy: Double
    let completed: Bool
    let date: Date
}

// MARK: - Player Statistics
struct PlayerStatistics: Codable {
    var totalSessions: Int
    var completedLevels: Int
    var currentStreak: Int
    var bestStreak: Int
    var averageAccuracy: Double
    var totalAccuracySum: Double
    var accuracyCount: Int
    var lastPlayedDate: Date?
    
    init() {
        totalSessions = 0
        completedLevels = 0
        currentStreak = 0
        bestStreak = 0
        averageAccuracy = 0
        totalAccuracySum = 0
        accuracyCount = 0
        lastPlayedDate = nil
    }
    
    mutating func updateAccuracy(_ accuracy: Double) {
        totalAccuracySum += accuracy
        accuracyCount += 1
        averageAccuracy = totalAccuracySum / Double(accuracyCount)
    }
}

// MARK: - Theme Colors Extension
// Note: primaryYellow, accentOrange, deepGreen are auto-generated from Assets
extension Color {
    // UI element colors
    static let cardBackground = Color.white.opacity(0.95)
    static let shadowColor = Color.black.opacity(0.1)
}

// MARK: - Gradient Helpers
extension LinearGradient {
    static let sunriseBackground = LinearGradient(
        colors: [
            Color.primaryYellow.opacity(0.3),
            Color.primaryYellow.opacity(0.6),
            Color.accentOrange.opacity(0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color.primaryYellow, Color.accentOrange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let greenGradient = LinearGradient(
        colors: [Color.deepGreen, Color.deepGreen.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

