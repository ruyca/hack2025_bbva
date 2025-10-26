//
//  BBVAButtonStyle.swift
//  BBVA
//
//  Modern Fintech button styles with enhanced visual effects
//

import SwiftUI

// MARK: - Primary Button Style (Blue with Gradient)
struct BBVAPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if configuration.isPressed {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVADarkRed,
                                Color.BBVADarkRed.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVAPrimaryRed,
                                Color.BBVADarkRed
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: configuration.isPressed ? Color.clear : Color.BBVAPrimaryRed.opacity(0.3),
                radius: configuration.isPressed ? 0 : 12,
                x: 0,
                y: configuration.isPressed ? 0 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style (Outlined with Hover Effect)
struct BBVASecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(configuration.isPressed ? Color.white : Color.BBVAPrimaryRed)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if configuration.isPressed {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVAPrimaryRed.opacity(0.9),
                                Color.BBVADarkRed.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVAPrimaryRed,
                                Color.BBVADarkRed
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: configuration.isPressed ? Color.clear : Color.BBVAPrimaryRed.opacity(0.15),
                radius: configuration.isPressed ? 0 : 8,
                x: 0,
                y: configuration.isPressed ? 0 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style (Text with Subtle Background)
struct BBVATertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(configuration.isPressed ? Color.BBVADarkRed : Color.BBVAPrimaryRed)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Color.BBVALightRed : Color.BBVALightRed.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Dark Button Style (Charcoal with Gradient)
struct BBVADarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        configuration.isPressed ? Color.BBVADarkGray : Color.BBVACharcoal,
                        configuration.isPressed ? Color.BBVADarkGray.opacity(0.8) : Color.BBVACharcoal.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: configuration.isPressed ? Color.clear : Color.black.opacity(0.2),
                radius: configuration.isPressed ? 0 : 10,
                x: 0,
                y: configuration.isPressed ? 0 : 5
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Success Button Style (Green)
struct BBVASuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        configuration.isPressed ? Color.BBVASuccess.opacity(0.8) : Color.BBVASuccess,
                        configuration.isPressed ? Color.BBVASuccess.opacity(0.7) : Color.BBVASuccess.opacity(0.85)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: configuration.isPressed ? Color.clear : Color.BBVASuccess.opacity(0.3),
                radius: configuration.isPressed ? 0 : 12,
                x: 0,
                y: configuration.isPressed ? 0 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style (Compact Round)
struct BBVAIconButtonStyle: ButtonStyle {
    var size: CGFloat = 48
    var backgroundColor: Color = Color.BBVALightRed
    var iconColor: Color = Color.BBVAPrimaryRed
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(configuration.isPressed ? iconColor.opacity(0.7) : iconColor)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func BBVAPrimaryButton() -> some View {
        self.buttonStyle(BBVAPrimaryButtonStyle())
    }
    
    func BBVASecondaryButton() -> some View {
        self.buttonStyle(BBVASecondaryButtonStyle())
    }
    
    func BBVATertiaryButton() -> some View {
        self.buttonStyle(BBVATertiaryButtonStyle())
    }
    
    func BBVADarkButton() -> some View {
        self.buttonStyle(BBVADarkButtonStyle())
    }
    
    func BBVASuccessButton() -> some View {
        self.buttonStyle(BBVASuccessButtonStyle())
    }
    
    func BBVAIconButton(size: CGFloat = 48, backgroundColor: Color = Color.BBVALightRed, iconColor: Color = Color.BBVAPrimaryRed) -> some View {
        self.buttonStyle(BBVAIconButtonStyle(size: size, backgroundColor: backgroundColor, iconColor: iconColor))
    }
}
