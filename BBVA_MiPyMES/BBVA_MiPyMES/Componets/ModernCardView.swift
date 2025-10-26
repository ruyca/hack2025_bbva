//
//  ModernCardView.swift
//  BBVA
//
//  Modern card component with various styles
//

import SwiftUI

// MARK: - Modern Card View
struct ModernCardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 20
    var shadowOpacity: Double = 0.08
    var padding: CGFloat = 24
    var backgroundColor: Color = .white
    var useGradient: Bool = false
    var gradientColors: [Color] = [.white, Color.BBVALightBlue.opacity(0.3)]
    
    init(
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 20,
        shadowOpacity: Double = 0.08,
        padding: CGFloat = 24,
        backgroundColor: Color = .white,
        useGradient: Bool = false,
        gradientColors: [Color] = [.white, Color.BBVALightBlue.opacity(0.3)],
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.useGradient = useGradient
        self.gradientColors = gradientColors
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if useGradient {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            }
            
            content
                .padding(padding)
        }
        .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 10)
    }
}

// MARK: - Glass Card View (Glassmorphism Effect)
struct GlassCardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 24
    
    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            content
                .padding(padding)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Gradient Card View
struct GradientCardView<Content: View>: View {
    let content: Content
    var colors: [Color]
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 24
    
    init(
        colors: [Color] = [Color.BBVAPrimaryRed, Color.BBVADarkRed],
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.colors = colors
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            content
                .padding(padding)
        }
        .shadow(color: colors[0].opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Bordered Card View
struct BorderedCardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 24
    var borderColor: Color = Color.BBVAPrimaryRed
    var borderWidth: CGFloat = 2
    var backgroundColor: Color = .white
    
    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 24,
        borderColor: Color = Color.BBVAPrimaryRed,
        borderWidth: CGFloat = 2,
        backgroundColor: Color = .white,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            
            content
                .padding(padding)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Preview
struct ModernCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ModernCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Standard Card")
                        .font(.headline)
                    Text("This is a modern card with shadow")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            GlassCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Glass Card")
                        .font(.headline)
                    Text("This is a glassmorphism card")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            GradientCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gradient Card")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("This is a gradient card")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            BorderedCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bordered Card")
                        .font(.headline)
                    Text("This is a bordered card")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.BBVABackground)
    }
}
