//
//  RhythmStepsGameView.swift
//  DF799
//

import SwiftUI

struct RhythmStepsGameView: View {
    @ObservedObject var gameManager: GameManager
    let difficulty: Difficulty
    let onDismiss: () -> Void
    
    @State private var gameState: RhythmGameState = .ready
    @State private var currentLevel = 1
    @State private var notes: [RhythmNote] = []
    @State private var score = 0
    @State private var combo = 0
    @State private var maxCombo = 0
    @State private var hitCount = 0
    @State private var missCount = 0
    @State private var perfectCount = 0
    @State private var goodCount = 0
    @State private var isPaused = false
    @State private var showVictory = false
    @State private var showDefeat = false
    @State private var gameTimer: Timer?
    @State private var hitZoneFlash: HitType?
    @State private var currentNoteIndex = 0
    @State private var gameProgress: Double = 0
    
    private let maxLevel = 10
    private let hitZoneY: CGFloat = UIScreen.main.bounds.height - 180
    private let noteSpeed: CGFloat = 4
    
    private var notesPerLevel: Int {
        switch difficulty {
        case .easy: return 8 + currentLevel * 2
        case .medium: return 12 + currentLevel * 2
        case .hard: return 16 + currentLevel * 2
        }
    }
    
    private var perfectWindow: Double {
        switch difficulty {
        case .easy: return 80
        case .medium: return 50
        case .hard: return 30
        }
    }
    
    private var goodWindow: Double {
        switch difficulty {
        case .easy: return 120
        case .medium: return 90
        case .hard: return 60
        }
    }
    
    private var noteInterval: Double {
        switch difficulty {
        case .easy: return 1.2 - Double(currentLevel) * 0.05
        case .medium: return 1.0 - Double(currentLevel) * 0.05
        case .hard: return 0.8 - Double(currentLevel) * 0.04
        }
    }
    
    private var laneCount: Int {
        switch difficulty {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            RhythmBackground()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                // Game content
                switch gameState {
                case .ready:
                    readyView
                case .playing:
                    playingView
                case .levelComplete:
                    levelCompleteView
                case .gameOver:
                    gameOverView
                }
            }
            
            // Pause overlay
            if isPaused {
                pauseOverlay
            }
        }
        .onAppear {
            // Ensure clean state on appear
            gameState = .ready
            currentLevel = 1
            notes = []
            score = 0
            combo = 0
            maxCombo = 0
            hitCount = 0
            missCount = 0
            perfectCount = 0
            goodCount = 0
            gameProgress = 0
            showVictory = false
            showDefeat = false
            isPaused = false
        }
        .onDisappear {
            stopGame()
        }
    }
    
    // MARK: - Header
    private var gameHeader: some View {
        HStack {
            Button(action: {
                stopGame()
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            if gameState == .playing {
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryYellow)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(combo > 0 ? .accentOrange : .white.opacity(0.5))
                        
                        Text("\(combo)x")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(combo > 0 ? .accentOrange : .white.opacity(0.5))
                    }
                }
            } else {
                VStack(spacing: 2) {
                    Text("Level \(currentLevel)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(difficulty.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Button(action: { isPaused = true }) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .opacity(gameState == .playing ? 1 : 0)
            .disabled(gameState != .playing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Ready View
    private var readyView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.accentOrange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "waveform.path")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.accentOrange)
            }
            
            VStack(spacing: 12) {
                Text("Rhythm Steps")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap when notes reach the hit zone. Build combos for higher scores!")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 8) {
                Text("Level \(currentLevel) of \(maxLevel)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(notesPerLevel) notes • \(laneCount) lanes")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.accentOrange)
            }
            
            Button(action: startGame) {
                HStack(spacing: 10) {
                    Text("Start")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .frame(width: 180, height: 54)
                .background(LinearGradient.warmGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.accentOrange.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        GeometryReader { geometry in
            ZStack {
                // Progress bar at top
                VStack {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primaryYellow)
                                .frame(width: geo.size.width * gameProgress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                // Lane dividers
                ForEach(0..<laneCount, id: \.self) { lane in
                    let laneWidth = (geometry.size.width - 40) / CGFloat(laneCount)
                    let xPosition = 20 + laneWidth * CGFloat(lane) + laneWidth / 2
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)
                        .position(x: xPosition, y: geometry.size.height / 2)
                }
                
                // Hit zone
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                hitZoneFlash == .perfect ? Color.green.opacity(0.6) :
                                hitZoneFlash == .good ? Color.yellow.opacity(0.6) :
                                hitZoneFlash == .miss ? Color.red.opacity(0.6) :
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                hitZoneFlash == .perfect ? Color.green :
                                hitZoneFlash == .good ? Color.yellow :
                                hitZoneFlash == .miss ? Color.red :
                                Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal, 20)
                    .position(x: geometry.size.width / 2, y: hitZoneY)
                
                // Notes - only render notes that are visible (on screen or about to appear)
                ForEach(notes) { note in
                    if note.isActive && !note.isHit && note.y > -100 {
                        NoteView(note: note, laneCount: laneCount, geometry: geometry)
                            .position(x: getLaneX(lane: note.lane, geometry: geometry), y: note.y)
                    }
                }
                
                // Lane tap buttons
                HStack(spacing: 10) {
                    ForEach(0..<laneCount, id: \.self) { lane in
                        LaneTapButton(
                            lane: lane,
                            laneCount: laneCount,
                            color: laneColors[lane % laneColors.count]
                        ) {
                            handleTap(lane: lane)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .position(x: geometry.size.width / 2, y: geometry.size.height - 80)
            }
        }
    }
    
    private let laneColors: [Color] = [.red, .blue, .green, .orange, .purple]
    
    private func getLaneX(lane: Int, geometry: GeometryProxy) -> CGFloat {
        let laneWidth = (geometry.size.width - 40) / CGFloat(laneCount)
        return 20 + laneWidth * CGFloat(lane) + laneWidth / 2
    }
    
    // MARK: - Level Complete View
    private var levelCompleteView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.deepGreen.opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.deepGreen)
            }
            .scaleEffect(showVictory ? 1 : 0.5)
            .opacity(showVictory ? 1 : 0)
            
            VStack(spacing: 12) {
                Text("Level Complete!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Score: \(score)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryYellow)
            }
            
            // Stats
            VStack(spacing: 12) {
                HStack(spacing: 30) {
                    StatItem(label: "Perfect", value: "\(perfectCount)", color: .green)
                    StatItem(label: "Good", value: "\(goodCount)", color: .yellow)
                    StatItem(label: "Miss", value: "\(missCount)", color: .red)
                }
                
                HStack(spacing: 30) {
                    StatItem(label: "Max Combo", value: "\(maxCombo)x", color: .accentOrange)
                    StatItem(label: "Accuracy", value: "\(Int(calculateAccuracy()))%", color: .primaryYellow)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if currentLevel < maxLevel {
                Button(action: nextLevel) {
                    HStack(spacing: 10) {
                        Text("Next Level")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 180, height: 54)
                    .background(LinearGradient.warmGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                VStack(spacing: 16) {
                    Text("All levels completed!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: {
                        saveProgress(completed: true)
                        onDismiss()
                    }) {
                        Text("Finish")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 180, height: 54)
                            .background(LinearGradient.greenGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                showVictory = true
            }
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red.opacity(0.8))
            }
            .scaleEffect(showDefeat ? 1 : 0.5)
            .opacity(showDefeat ? 1 : 0)
            
            VStack(spacing: 12) {
                Text("Too Many Misses!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Score: \(score)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Stats
            HStack(spacing: 30) {
                StatItem(label: "Perfect", value: "\(perfectCount)", color: .green)
                StatItem(label: "Good", value: "\(goodCount)", color: .yellow)
                StatItem(label: "Max Combo", value: "\(maxCombo)x", color: .accentOrange)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            HStack(spacing: 16) {
                Button(action: restartGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Retry")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(width: 130, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: {
                    saveProgress(completed: false)
                    onDismiss()
                }) {
                    Text("Exit")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 130, height: 50)
                        .background(LinearGradient.warmGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                showDefeat = true
            }
        }
    }
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Paused")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: { isPaused = false }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            
                            Text("Resume")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 54)
                        .background(LinearGradient.warmGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button(action: restartGame) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16))
                            
                            Text("Restart")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 54)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button(action: {
                        stopGame()
                        saveProgress(completed: false)
                        onDismiss()
                    }) {
                        Text("Exit")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        generateNotes()
        gameState = .playing
        currentNoteIndex = 0
        gameProgress = 0
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            guard !isPaused else { return }
            updateGame()
        }
    }
    
    private func generateNotes() {
        notes = []
        let spawnY: CGFloat = -50 // Start above the screen
        
        // Calculate how far apart notes should be based on interval and speed
        // noteInterval is in seconds, noteSpeed is pixels per frame at 60fps
        let pixelsPerSecond = noteSpeed * 60.0
        let spacingBetweenNotes = CGFloat(noteInterval) * pixelsPerSecond
        
        for i in 0..<notesPerLevel {
            let lane = Int.random(in: 0..<laneCount)
            // Each note starts higher up, spaced by the timing interval converted to pixels
            let initialY = spawnY - CGFloat(i) * spacingBetweenNotes
            let note = RhythmNote(
                id: i,
                lane: lane,
                targetTime: Double(i) * noteInterval,
                y: initialY
            )
            notes.append(note)
        }
    }
    
    private func updateGame() {
        // Move notes down
        for i in 0..<notes.count {
            if notes[i].isActive && !notes[i].isHit {
                notes[i].y += noteSpeed
                
                // Check if note passed hit zone (missed)
                if notes[i].y > hitZoneY + 60 {
                    notes[i].isActive = false
                    registerMiss()
                }
            }
        }
        
        // Update progress based on notes that have been processed (hit or missed)
        let processedNotes = notes.filter { $0.isHit || (!$0.isActive && $0.y > hitZoneY) }.count
        gameProgress = min(1.0, Double(processedNotes) / Double(notesPerLevel))
        
        // Check for level complete - all notes have been either hit or passed
        let allNotesProcessed = notes.allSatisfy { $0.isHit || !$0.isActive }
        let lastNoteProcessed = notes.last.map { !$0.isActive || $0.isHit } ?? true
        
        if allNotesProcessed && lastNoteProcessed && !notes.isEmpty && gameState == .playing {
            stopGame()
            withAnimation {
                gameState = .levelComplete
            }
        }
    }
    
    private func handleTap(lane: Int) {
        // Find closest active note in this lane
        let laneNotes = notes.enumerated().filter { 
            $0.element.lane == lane && 
            $0.element.isActive && 
            !$0.element.isHit 
        }
        
        guard let closest = laneNotes.min(by: { abs($0.element.y - hitZoneY) < abs($1.element.y - hitZoneY) }) else {
            return
        }
        
        let distance = abs(closest.element.y - hitZoneY)
        
        if distance <= perfectWindow {
            notes[closest.offset].isHit = true
            notes[closest.offset].isActive = false
            registerHit(type: .perfect)
        } else if distance <= goodWindow {
            notes[closest.offset].isHit = true
            notes[closest.offset].isActive = false
            registerHit(type: .good)
        }
    }
    
    private func registerHit(type: HitType) {
        hitCount += 1
        combo += 1
        maxCombo = max(maxCombo, combo)
        
        let baseScore: Int
        switch type {
        case .perfect:
            perfectCount += 1
            baseScore = 100
        case .good:
            goodCount += 1
            baseScore = 50
        case .miss:
            baseScore = 0
        }
        
        score += baseScore * (1 + combo / 10) * difficulty.scoreMultiplier
        
        withAnimation(.easeOut(duration: 0.15)) {
            hitZoneFlash = type
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
                hitZoneFlash = nil
            }
        }
    }
    
    private func registerMiss() {
        missCount += 1
        combo = 0
        
        withAnimation(.easeOut(duration: 0.15)) {
            hitZoneFlash = .miss
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
                hitZoneFlash = nil
            }
        }
        
        // Game over if too many misses
        let maxMisses: Int = {
            switch difficulty {
            case .easy: return notesPerLevel / 2
            case .medium: return notesPerLevel / 3
            case .hard: return notesPerLevel / 4
            }
        }()
        
        if missCount >= maxMisses {
            stopGame()
            withAnimation {
                gameState = .gameOver
            }
        }
    }
    
    private func calculateAccuracy() -> Double {
        let total = hitCount + missCount
        guard total > 0 else { return 0 }
        return Double(hitCount) / Double(total) * 100
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func nextLevel() {
        // Save progress for completed level
        saveProgress(completed: true)
        showVictory = false
        currentLevel += 1
        resetLevelState()
        gameState = .ready
    }
    
    private func restartGame() {
        stopGame()
        isPaused = false
        showVictory = false
        showDefeat = false
        currentLevel = 1
        // Full reset on restart
        notes = []
        score = 0
        combo = 0
        maxCombo = 0
        hitCount = 0
        missCount = 0
        perfectCount = 0
        goodCount = 0
        gameProgress = 0
        gameState = .ready
    }
    
    private func resetLevelState() {
        notes = []
        // Keep score accumulated across levels
        combo = 0
        // Keep maxCombo as personal best
        hitCount = 0
        missCount = 0
        perfectCount = 0
        goodCount = 0
        gameProgress = 0
    }
    
    private func saveProgress(completed: Bool) {
        gameManager.recordGameSession(
            gameType: .rhythmSteps,
            difficulty: difficulty,
            level: currentLevel,
            score: score,
            accuracy: calculateAccuracy(),
            completed: completed
        )
    }
}

// MARK: - Rhythm Note Model
struct RhythmNote: Identifiable {
    let id: Int
    let lane: Int
    let targetTime: Double
    var y: CGFloat
    var isActive: Bool = true
    var isHit: Bool = false
}

// MARK: - Hit Type
enum HitType {
    case perfect
    case good
    case miss
}

// MARK: - Game State
enum RhythmGameState {
    case ready
    case playing
    case levelComplete
    case gameOver
}

// MARK: - Note View
struct NoteView: View {
    let note: RhythmNote
    let laneCount: Int
    let geometry: GeometryProxy
    
    private let colors: [Color] = [.red, .blue, .green, .orange, .purple]
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        colors[note.lane % colors.count],
                        colors[note.lane % colors.count].opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 50, height: 50)
            .shadow(color: colors[note.lane % colors.count].opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Lane Tap Button
struct LaneTapButton: View {
    let lane: Int
    let laneCount: Int
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.1)) {
                isPressed = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(color: color.opacity(0.4), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Rhythm Background
struct RhythmBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.1, green: 0.08, blue: 0.2),
                    Color.deepGreen.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.accentOrange.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: geometry.size.width - 100, y: 100)
                
                Circle()
                    .fill(Color.primaryYellow.opacity(0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: -50, y: geometry.size.height - 300)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RhythmStepsGameView(
        gameManager: GameManager.shared,
        difficulty: .medium,
        onDismiss: {}
    )
}

