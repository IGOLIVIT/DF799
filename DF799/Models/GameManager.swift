//
//  GameManager.swift
//  DF799
//

import SwiftUI
import Combine

class GameManager: ObservableObject {
    static let shared = GameManager()
    
    // MARK: - Published Properties
    @Published var hasCompletedOnboarding: Bool {
        didSet { saveOnboardingState() }
    }
    @Published var statistics: PlayerStatistics {
        didSet { saveStatistics() }
    }
    @Published var badges: [Badge] {
        didSet { saveBadges() }
    }
    @Published var levelProgress: [String: LevelProgress] {
        didSet { saveLevelProgress() }
    }
    @Published var gameSessions: [GameSession] {
        didSet { saveGameSessions() }
    }
    
    // MARK: - Keys
    private let onboardingKey = "hasCompletedOnboarding"
    private let statisticsKey = "playerStatistics"
    private let badgesKey = "playerBadges"
    private let levelProgressKey = "levelProgress"
    private let gameSessionsKey = "gameSessions"
    
    // MARK: - Initialization
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        self.statistics = PlayerStatistics()
        self.badges = []
        self.levelProgress = [:]
        self.gameSessions = []
        
        loadData()
        initializeBadgesIfNeeded()
    }
    
    // MARK: - Badge Definitions
    private func createDefaultBadges() -> [Badge] {
        return [
            Badge(
                id: "focused_step",
                name: "Focused Step",
                description: "Complete your first challenge with focus and determination",
                iconName: "figure.walk",
                requirement: BadgeRequirement(type: .completeLevels, value: 1, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "swift_move",
                name: "Swift Move",
                description: "Complete 5 levels across any challenge",
                iconName: "bolt.fill",
                requirement: BadgeRequirement(type: .completeLevels, value: 5, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "calm_precision",
                name: "Calm Precision",
                description: "Achieve 90% accuracy in any challenge",
                iconName: "target",
                requirement: BadgeRequirement(type: .perfectAccuracy, value: 90, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "path_master",
                name: "Path Master",
                description: "Complete 10 Path Tiles challenges",
                iconName: "square.grid.3x3.fill",
                requirement: BadgeRequirement(type: .completeLevels, value: 10, gameType: .pathTiles),
                isUnlocked: false
            ),
            Badge(
                id: "rhythm_keeper",
                name: "Rhythm Keeper",
                description: "Complete 10 Rhythm Steps challenges",
                iconName: "waveform.path",
                requirement: BadgeRequirement(type: .completeLevels, value: 10, gameType: .rhythmSteps),
                isUnlocked: false
            ),
            Badge(
                id: "steady_progress",
                name: "Steady Progress",
                description: "Achieve a 3-level winning streak",
                iconName: "flame.fill",
                requirement: BadgeRequirement(type: .achieveStreak, value: 3, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "dedicated_traveler",
                name: "Dedicated Traveler",
                description: "Complete 10 play sessions",
                iconName: "star.fill",
                requirement: BadgeRequirement(type: .totalSessions, value: 10, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "challenge_seeker",
                name: "Challenge Seeker",
                description: "Complete a level on Hard difficulty",
                iconName: "crown.fill",
                requirement: BadgeRequirement(type: .completeHardMode, value: 1, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "rising_sun",
                name: "Rising Sun",
                description: "Complete 25 levels total",
                iconName: "sun.max.fill",
                requirement: BadgeRequirement(type: .completeLevels, value: 25, gameType: nil),
                isUnlocked: false
            ),
            Badge(
                id: "golden_path",
                name: "Golden Path",
                description: "Achieve a 10-level winning streak",
                iconName: "sparkles",
                requirement: BadgeRequirement(type: .achieveStreak, value: 10, gameType: nil),
                isUnlocked: false
            )
        ]
    }
    
    private func initializeBadgesIfNeeded() {
        if badges.isEmpty {
            badges = createDefaultBadges()
        }
    }
    
    // MARK: - Game Progress Methods
    func recordGameSession(gameType: GameType, difficulty: Difficulty, level: Int, score: Int, accuracy: Double, completed: Bool) {
        let session = GameSession(
            id: UUID(),
            gameType: gameType,
            difficulty: difficulty,
            level: level,
            score: score,
            accuracy: accuracy,
            completed: completed,
            date: Date()
        )
        
        gameSessions.append(session)
        statistics.totalSessions += 1
        statistics.updateAccuracy(accuracy)
        statistics.lastPlayedDate = Date()
        
        if completed {
            statistics.completedLevels += 1
            statistics.currentStreak += 1
            if statistics.currentStreak > statistics.bestStreak {
                statistics.bestStreak = statistics.currentStreak
            }
            
            updateLevelProgress(gameType: gameType, difficulty: difficulty, level: level, score: score, accuracy: accuracy)
        } else {
            statistics.currentStreak = 0
        }
        
        checkAndUnlockBadges(gameType: gameType, difficulty: difficulty, accuracy: accuracy)
    }
    
    private func updateLevelProgress(gameType: GameType, difficulty: Difficulty, level: Int, score: Int, accuracy: Double) {
        let key = "\(gameType.rawValue)_\(difficulty.rawValue)_\(level)"
        
        if var existing = levelProgress[key] {
            existing.attempts += 1
            existing.completed = true
            if score > existing.bestScore {
                existing.bestScore = score
            }
            if accuracy > existing.bestAccuracy {
                existing.bestAccuracy = accuracy
            }
            levelProgress[key] = existing
        } else {
            levelProgress[key] = LevelProgress(
                gameType: gameType,
                difficulty: difficulty,
                level: level,
                bestScore: score,
                completed: true,
                attempts: 1,
                bestAccuracy: accuracy
            )
        }
    }
    
    private func checkAndUnlockBadges(gameType: GameType, difficulty: Difficulty, accuracy: Double) {
        for i in 0..<badges.count {
            guard !badges[i].isUnlocked else { continue }
            
            let requirement = badges[i].requirement
            var shouldUnlock = false
            
            switch requirement.type {
            case .completeLevels:
                if let requiredGame = requirement.gameType {
                    let count = gameSessions.filter { $0.gameType == requiredGame && $0.completed }.count
                    shouldUnlock = count >= requirement.value
                } else {
                    shouldUnlock = statistics.completedLevels >= requirement.value
                }
                
            case .achieveStreak:
                shouldUnlock = statistics.bestStreak >= requirement.value
                
            case .perfectAccuracy:
                shouldUnlock = accuracy >= Double(requirement.value)
                
            case .completeHardMode:
                let hardCompletions = gameSessions.filter { $0.difficulty == .hard && $0.completed }.count
                shouldUnlock = hardCompletions >= requirement.value
                
            case .totalSessions:
                shouldUnlock = statistics.totalSessions >= requirement.value
            }
            
            if shouldUnlock {
                badges[i].isUnlocked = true
                badges[i].unlockedDate = Date()
            }
        }
    }
    
    // MARK: - Progress Queries
    func getCompletedLevelsCount(for gameType: GameType) -> Int {
        return levelProgress.values.filter { $0.gameType == gameType && $0.completed }.count
    }
    
    func getHighestCompletedLevel(for gameType: GameType, difficulty: Difficulty) -> Int {
        let levels = levelProgress.values.filter {
            $0.gameType == gameType && $0.difficulty == difficulty && $0.completed
        }
        return levels.map { $0.level }.max() ?? 0
    }
    
    func isLevelUnlocked(gameType: GameType, difficulty: Difficulty, level: Int) -> Bool {
        if level == 1 { return true }
        return getHighestCompletedLevel(for: gameType, difficulty: difficulty) >= level - 1
    }
    
    func getBestScore(for gameType: GameType, difficulty: Difficulty, level: Int) -> Int? {
        let key = "\(gameType.rawValue)_\(difficulty.rawValue)_\(level)"
        return levelProgress[key]?.bestScore
    }
    
    func getUnlockedBadges() -> [Badge] {
        return badges.filter { $0.isUnlocked }
    }
    
    func getLockedBadges() -> [Badge] {
        return badges.filter { !$0.isUnlocked }
    }
    
    // MARK: - Reset
    func resetAllProgress() {
        statistics = PlayerStatistics()
        badges = createDefaultBadges()
        levelProgress = [:]
        gameSessions = []
    }
    
    // MARK: - Persistence
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode(PlayerStatistics.self, from: data) {
            statistics = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            badges = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: levelProgressKey),
           let decoded = try? JSONDecoder().decode([String: LevelProgress].self, from: data) {
            levelProgress = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: gameSessionsKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            gameSessions = decoded
        }
    }
    
    private func saveOnboardingState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey)
    }
    
    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
    
    private func saveBadges() {
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }
    
    private func saveLevelProgress() {
        if let encoded = try? JSONEncoder().encode(levelProgress) {
            UserDefaults.standard.set(encoded, forKey: levelProgressKey)
        }
    }
    
    private func saveGameSessions() {
        if let encoded = try? JSONEncoder().encode(gameSessions) {
            UserDefaults.standard.set(encoded, forKey: gameSessionsKey)
        }
    }
}

