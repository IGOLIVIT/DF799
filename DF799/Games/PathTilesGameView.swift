//
//  PathTilesGameView.swift
//  DF799
//

import SwiftUI

struct PathTilesGameView: View {
    @ObservedObject var gameManager: GameManager
    let difficulty: Difficulty
    let onDismiss: () -> Void
    
    @State private var gameState: PathTilesGameState = .ready
    @State private var currentLevel = 1
    @State private var tiles: [PathTile] = []
    @State private var correctSequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var showingSequence = false
    @State private var currentShowIndex = 0
    @State private var highlightedTileId: Int? = nil
    @State private var timeRemaining: Double = 0
    @State private var score = 0
    @State private var totalAccuracy: Double = 0
    @State private var attemptsCount = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var showVictory = false
    @State private var showDefeat = false
    
    private let maxLevel = 10
    
    private var gridSize: Int {
        switch difficulty {
        case .easy: return min(2 + currentLevel / 3, 4)
        case .medium: return min(3 + currentLevel / 3, 5)
        case .hard: return min(3 + currentLevel / 2, 6)
        }
    }
    
    private var sequenceLength: Int {
        switch difficulty {
        case .easy: return min(2 + currentLevel, 6)
        case .medium: return min(3 + currentLevel, 8)
        case .hard: return min(4 + currentLevel, 10)
        }
    }
    
    private var baseTime: Double {
        switch difficulty {
        case .easy: return 15.0
        case .medium: return 12.0
        case .hard: return 8.0
        }
    }
    
    private var timePerTile: Double {
        switch difficulty {
        case .easy: return 2.0
        case .medium: return 1.5
        case .hard: return 1.0
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            GameBackground()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                Spacer()
                
                // Game content
                switch gameState {
                case .ready:
                    readyView
                case .showingSequence:
                    sequenceView
                case .playing:
                    playingView
                case .levelComplete:
                    levelCompleteView
                case .gameOver:
                    gameOverView
                }
                
                Spacer()
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
            tiles = []
            correctSequence = []
            playerSequence = []
            highlightedTileId = nil
            score = 0
            totalAccuracy = 0
            attemptsCount = 0
            showVictory = false
            showDefeat = false
            isPaused = false
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Header
    private var gameHeader: some View {
        HStack {
            Button(action: {
                timer?.invalidate()
                timer = nil
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
            
            VStack(spacing: 2) {
                Text("Level \(currentLevel)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(difficulty.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
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
            ZStack {
                Circle()
                    .fill(Color.primaryYellow.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.primaryYellow)
            }
            
            VStack(spacing: 12) {
                Text("Path Tiles")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Watch the sequence, then tap the tiles in the same order")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 8) {
                Text("Level \(currentLevel) of \(maxLevel)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(sequenceLength) tiles to follow")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primaryYellow)
            }
            
            Button(action: startLevel) {
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
        }
    }
    
    // MARK: - Sequence View
    private var sequenceView: some View {
        VStack(spacing: 30) {
            Text("Watch carefully...")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            tileGrid(interactive: false)
            
            HStack(spacing: 8) {
                ForEach(0..<sequenceLength, id: \.self) { index in
                    Circle()
                        .fill(index < currentShowIndex ? Color.primaryYellow : Color.white.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 20) {
            // Timer bar
            VStack(spacing: 8) {
                HStack {
                    Text("Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(String(format: "%.1fs", timeRemaining))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(timeRemaining < 3 ? .red : .white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(timeRemaining < 3 ? Color.red : Color.primaryYellow)
                            .frame(width: geometry.size.width * CGFloat(timeRemaining / (baseTime + Double(sequenceLength) * timePerTile)))
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, 30)
            
            // Progress
            HStack {
                Text("Progress:")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(playerSequence.count) / \(sequenceLength)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryYellow)
            }
            
            tileGrid(interactive: true)
            
            Text("Tap the tiles in the correct order")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tile Grid
    private func tileGrid(interactive: Bool) -> some View {
        let tileSize: CGFloat = min(60, (UIScreen.main.bounds.width - 80) / CGFloat(gridSize) - 10)
        
        return LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(tileSize), spacing: 10), count: gridSize),
            spacing: 10
        ) {
            ForEach(tiles) { tile in
                TileView(
                    tile: tile,
                    size: tileSize,
                    isHighlighted: highlightedTileId == tile.id,
                    isSelected: playerSequence.contains(tile.id),
                    interactive: interactive && !showingSequence
                ) {
                    if interactive && !showingSequence {
                        tileTapped(tile)
                    }
                }
            }
        }
    }
    
    // MARK: - Level Complete View
    private var levelCompleteView: some View {
        VStack(spacing: 30) {
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
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showVictory)
            
            VStack(spacing: 12) {
                Text("Level Complete!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Score: \(score)")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryYellow)
            }
            
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
                    Text("Congratulations!")
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
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                showVictory = true
            }
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 30) {
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
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showDefeat)
            
            VStack(spacing: 12) {
                Text("Time's Up!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("You reached level \(currentLevel)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
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
    private func startLevel() {
        setupTiles()
        generateSequence()
        gameState = .showingSequence
        showSequence()
    }
    
    private func setupTiles() {
        tiles = (0..<(gridSize * gridSize)).map { index in
            PathTile(
                id: index,
                color: tileColors[index % tileColors.count]
            )
        }
    }
    
    private let tileColors: [Color] = [
        .red, .blue, .green, .orange, .purple, .pink, .cyan, .yellow, .mint, .indigo
    ]
    
    private func generateSequence() {
        correctSequence = []
        var availableIndices = Array(0..<tiles.count)
        
        for _ in 0..<sequenceLength {
            if let randomIndex = availableIndices.randomElement() {
                correctSequence.append(randomIndex)
                // Allow repeats for harder levels
                if difficulty != .hard {
                    availableIndices.removeAll { $0 == randomIndex }
                }
            }
        }
        
        playerSequence = []
    }
    
    private func showSequence() {
        currentShowIndex = 0
        highlightedTileId = nil
        
        // Duration each tile stays highlighted
        let highlightDuration: Double = {
            switch difficulty {
            case .easy: return 0.6
            case .medium: return 0.5
            case .hard: return 0.35
            }
        }()
        
        // Pause between tiles
        let pauseDuration: Double = 0.2
        
        func showNext() {
            guard currentShowIndex < correctSequence.count else {
                // All tiles shown, wait a moment then start playing
                highlightedTileId = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        gameState = .playing
                        startTimer()
                    }
                }
                return
            }
            
            // Highlight the current tile
            let tileId = correctSequence[currentShowIndex]
            withAnimation(.easeInOut(duration: 0.15)) {
                highlightedTileId = tileId
            }
            
            // After highlight duration, turn off and move to next
            DispatchQueue.main.asyncAfter(deadline: .now() + highlightDuration) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    highlightedTileId = nil
                }
                
                currentShowIndex += 1
                
                // After pause, show next tile
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    showNext()
                }
            }
        }
        
        // Start showing sequence after initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showNext()
        }
    }
    
    private func startTimer() {
        timeRemaining = baseTime + Double(sequenceLength) * timePerTile
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard !isPaused else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                timer?.invalidate()
                timer = nil
                withAnimation {
                    gameState = .gameOver
                }
            }
        }
    }
    
    private func tileTapped(_ tile: PathTile) {
        guard !playerSequence.contains(tile.id) else { return }
        
        let expectedIndex = playerSequence.count
        let expectedTileId = correctSequence[expectedIndex]
        
        if tile.id == expectedTileId {
            withAnimation(.spring(response: 0.3)) {
                playerSequence.append(tile.id)
            }
            
            if playerSequence.count == correctSequence.count {
                timer?.invalidate()
                timer = nil
                
                let accuracy = 100.0
                totalAccuracy += accuracy
                attemptsCount += 1
                score += Int(timeRemaining * 10) * difficulty.scoreMultiplier
                
                withAnimation {
                    gameState = .levelComplete
                }
            }
        } else {
            // Wrong tile - game over
            timer?.invalidate()
            timer = nil
            
            totalAccuracy += Double(playerSequence.count) / Double(correctSequence.count) * 100
            attemptsCount += 1
            
            withAnimation {
                gameState = .gameOver
            }
        }
    }
    
    private func nextLevel() {
        // Save progress for completed level
        saveProgress(completed: true)
        showVictory = false
        currentLevel += 1
        gameState = .ready
    }
    
    private func restartGame() {
        timer?.invalidate()
        timer = nil
        isPaused = false
        showVictory = false
        showDefeat = false
        highlightedTileId = nil
        currentLevel = 1
        score = 0
        totalAccuracy = 0
        attemptsCount = 0
        gameState = .ready
    }
    
    private func saveProgress(completed: Bool) {
        let avgAccuracy = attemptsCount > 0 ? totalAccuracy / Double(attemptsCount) : 0
        gameManager.recordGameSession(
            gameType: .pathTiles,
            difficulty: difficulty,
            level: currentLevel,
            score: score,
            accuracy: avgAccuracy,
            completed: completed
        )
    }
}

// MARK: - Path Tile Model
struct PathTile: Identifiable {
    let id: Int
    let color: Color
}

// MARK: - Game State
enum PathTilesGameState {
    case ready
    case showingSequence
    case playing
    case levelComplete
    case gameOver
}

// MARK: - Tile View
struct TileView: View {
    let tile: PathTile
    let size: CGFloat
    let isHighlighted: Bool
    let isSelected: Bool
    let interactive: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if interactive {
                onTap()
            }
        }) {
            ZStack {
                // Outer glow when highlighted
                if isHighlighted {
                    RoundedRectangle(cornerRadius: size / 5)
                        .fill(Color.white)
                        .frame(width: size + 12, height: size + 12)
                        .blur(radius: 8)
                        .opacity(0.8)
                }
                
                RoundedRectangle(cornerRadius: size / 5)
                    .fill(
                        LinearGradient(
                            colors: isHighlighted ? [.white, tile.color] : [tile.color, tile.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: size / 5)
                            .stroke(Color.white, lineWidth: isHighlighted ? 5 : (isSelected ? 3 : 0))
                    )
                    .shadow(
                        color: isHighlighted ? Color.white : tile.color.opacity(0.4),
                        radius: isHighlighted ? 15 : 4,
                        x: 0,
                        y: isHighlighted ? 0 : 4
                    )
            }
            .scaleEffect(isHighlighted ? 1.15 : (isPressed ? 0.95 : 1.0))
            .opacity(isSelected ? 0.5 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!interactive || isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHighlighted)
        .animation(.spring(response: 0.2), value: isPressed)
    }
}

// MARK: - Game Background
struct GameBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.deepGreen.opacity(0.95),
                    Color.deepGreen,
                    Color.deepGreen.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.primaryYellow.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.accentOrange.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PathTilesGameView(
        gameManager: GameManager.shared,
        difficulty: .medium,
        onDismiss: {}
    )
}

