//
//  ModernAnimations.swift
//  BBVA
//
//  Modern animation and transition utilities
//

import SwiftUI

// MARK: - Custom Animations
extension Animation {
    // Smooth spring animation
    static var smoothSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // Quick spring animation
    static var quickSpring: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // Bouncy animation
    static var bouncy: Animation {
        .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
    }
    
    // Smooth ease
    static var smoothEase: Animation {
        .easeInOut(duration: 0.3)
    }
}

// MARK: - View Modifiers for Animations
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.3)
                    .offset(x: phase * geometry.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    var minScale: CGFloat = 0.95
    var maxScale: CGFloat = 1.05
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    var offset: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

struct SlideInEffect: ViewModifier {
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

struct ScaleInEffect: ViewModifier {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

struct RotateEffect: ViewModifier {
    @State private var rotation: Double = 0
    var duration: Double = 1.0
    var repeatForever: Bool = true
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if repeatForever {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    withAnimation(.linear(duration: duration)) {
                        rotation = 360
                    }
                }
            }
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    @State private var isAnimating = false
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVALightGray.opacity(0.5),
                        Color.BBVALightGray.opacity(0.8),
                        Color.BBVALightGray.opacity(0.5)
                    ]),
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
    
    func pulse(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05) -> some View {
        self.modifier(PulseEffect(minScale: minScale, maxScale: maxScale))
    }
    
    func floating(offset: CGFloat = 10) -> some View {
        self.modifier(FloatingEffect(offset: offset))
    }
    
    func slideIn(delay: Double = 0) -> some View {
        self.modifier(SlideInEffect(delay: delay))
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInEffect(delay: delay))
    }
    
    func rotate(duration: Double = 1.0, repeatForever: Bool = true) -> some View {
        self.modifier(RotateEffect(duration: duration, repeatForever: repeatForever))
    }
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Preview
struct ModernAnimations_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Shimmer effect
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.BBVAPrimaryRed)
                .frame(width: 200, height: 50)
                .shimmer()
            
            // Pulse effect
            Circle()
                .fill(Color.BBVATeal)
                .frame(width: 60, height: 60)
                .pulse()
            
            // Floating effect
            Image(systemName: "cloud.fill")
                .font(.system(size: 50))
                .foregroundColor(Color.BBVALightBlue)
                .floating()
            
            // Skeleton loading
            VStack(spacing: 12) {
                SkeletonView()
                    .frame(height: 20)
                
                SkeletonView()
                    .frame(height: 20)
                    .frame(maxWidth: 200)
                
                SkeletonView()
                    .frame(height: 20)
                    .frame(maxWidth: 150)
            }
            .padding()
        }
        .padding()
        .background(Color.BBVABackground)
    }
}
