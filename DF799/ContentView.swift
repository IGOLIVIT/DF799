//
//  ContentView.swift
//  DF799
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !gameManager.hasCompletedOnboarding {
                OnboardingView(gameManager: gameManager)
                    .transition(.opacity)
            } else {
                MainTabView(gameManager: gameManager, selectedTab: $selectedTab)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: gameManager.hasCompletedOnboarding)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                HomeView(gameManager: gameManager, selectedTab: $selectedTab)
                    .tag(0)
                
                ProgressView(gameManager: gameManager)
                    .tag(1)
                
                SettingsView(gameManager: gameManager)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("rosette", "Progress"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            TabBarBackground()
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primaryYellow : .white.opacity(0.5))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .primaryYellow : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                isSelected ?
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryYellow.opacity(0.15))
                    .padding(.horizontal, 10)
                : nil
            )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Tab Bar Background
struct TabBarBackground: View {
    var body: some View {
        ZStack {
            // Blur effect background
            Rectangle()
                .fill(Color.deepGreen.opacity(0.95))
            
            // Top gradient overlay for smooth blend
            VStack {
                LinearGradient(
                    colors: [Color.clear, Color.deepGreen.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                
                Spacer()
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

#Preview {
    ContentView()
}
