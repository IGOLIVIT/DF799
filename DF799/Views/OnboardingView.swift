//
//  OnboardingView.swift
//  DF799
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "sparkles",
            title: "Quick Challenges",
            description: "Engage with short, focused mini-games designed to sharpen your mind and bring calm satisfaction",
            decorativeIcons: ["star.fill", "bolt.fill", "heart.fill"]
        ),
        OnboardingSlide(
            icon: "arrow.up.right",
            title: "Progress Forward",
            description: "Each challenge completed moves you further along your personal path of growth and achievement",
            decorativeIcons: ["flag.fill", "trophy.fill", "target"]
        ),
        OnboardingSlide(
            icon: "rosette",
            title: "Collect Badges",
            description: "Earn unique badges as rewards for your dedication—no coins, just meaningful milestones",
            decorativeIcons: ["crown.fill", "flame.fill", "star.circle.fill"]
        ),
        OnboardingSlide(
            icon: "sun.max.fill",
            title: "Begin Your Journey",
            description: "Every great path starts with a single step. Your adventure awaits right here",
            decorativeIcons: ["sunrise.fill", "moon.fill", "sparkle"]
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        OnboardingSlideView(slide: slides[index], isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicators and button
                VStack(spacing: 30) {
                    // Custom page indicator
                    HStack(spacing: 10) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.accentOrange : Color.white.opacity(0.5))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Navigation button
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            if currentPage < slides.count - 1 {
                                currentPage += 1
                            } else {
                                gameManager.hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(currentPage < slides.count - 1 ? "Continue" : "Start")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
                            Image(systemName: currentPage < slides.count - 1 ? "arrow.right" : "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient.warmGradient
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.accentOrange.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 40)
                    
                    // Skip button (only on non-last slides)
                    if currentPage < slides.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage = slides.count - 1
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text(" ")
                            .font(.system(size: 15))
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Onboarding Slide Model
struct OnboardingSlide {
    let icon: String
    let title: String
    let description: String
    let decorativeIcons: [String]
}

// MARK: - Onboarding Slide View
struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var decorativeOffset: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Decorative floating icons
            ZStack {
                ForEach(0..<slide.decorativeIcons.count, id: \.self) { index in
                    Image(systemName: slide.decorativeIcons[index])
                        .font(.system(size: 24))
                        .foregroundColor(Color.primaryYellow.opacity(0.6))
                        .offset(
                            x: CGFloat([-60, 70, -40][index]),
                            y: CGFloat([-80, -50, 60][index]) + (isActive ? 0 : decorativeOffset)
                        )
                        .opacity(isActive ? 0.8 : 0)
                        .animation(.spring(response: 0.6).delay(Double(index) * 0.1), value: isActive)
                }
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.accentOrange.opacity(0.3), Color.primaryYellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.accentOrange, Color.primaryYellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.accentOrange.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: slide.icon)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
            }
            .frame(height: 200)
            
            // Text content
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(slide.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            .opacity(textOpacity)
            
            Spacer()
            Spacer()
        }
        .onChange(of: isActive) { _, active in
            if active {
                animateIn()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateIn()
                }
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            textOpacity = 1.0
        }
    }
    
    private func resetAnimation() {
        iconScale = 0.5
        iconOpacity = 0
        textOpacity = 0
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.deepGreen,
                    Color.deepGreen.opacity(0.9),
                    Color.deepGreen.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated circles
            GeometryReader { geometry in
                Circle()
                    .fill(Color.primaryYellow.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: animate ? geometry.size.width * 0.3 : geometry.size.width * 0.1,
                        y: animate ? geometry.size.height * 0.2 : geometry.size.height * 0.1
                    )
                
                Circle()
                    .fill(Color.accentOrange.opacity(0.12))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(
                        x: animate ? geometry.size.width * 0.6 : geometry.size.width * 0.7,
                        y: animate ? geometry.size.height * 0.6 : geometry.size.height * 0.7
                    )
                
                Circle()
                    .fill(Color.primaryYellow.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: animate ? -50 : 0,
                        y: animate ? geometry.size.height * 0.8 : geometry.size.height * 0.9
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView(gameManager: GameManager.shared)
}

