//
//  ModernBadgeView.swift
//  BBVA
//
//  Modern badge/chip components
//

import SwiftUI

// MARK: - Status Badge
struct StatusBadge: View {
    enum BadgeType {
        case success
        case warning
        case error
        case info
        case neutral
        
        var color: Color {
            switch self {
            case .success: return Color.BBVASuccess
            case .warning: return Color.BBVAWarning
            case .error: return Color.BBVAError
            case .info: return Color.BBVATeal
            case .neutral: return Color.BBVAMediumGray
            }
        }
    }
    
    let text: String
    let type: BadgeType
    var size: BadgeSize = .medium
    var icon: String? = nil
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 11
            case .medium: return 13
            case .large: return 15
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.fontSize, weight: .semibold))
            }
            
            Text(text)
                .font(.system(size: size.fontSize, weight: .semibold))
        }
        .foregroundColor(type.color)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(type.color.opacity(0.15))
        )
    }
}

// MARK: - Number Badge (for notifications)
struct NumberBadge: View {
    let count: Int
    var size: CGFloat = 20
    var backgroundColor: Color = Color.BBVAError
    var textColor: Color = .white
    
    var displayText: String {
        count > 99 ? "99+" : "\(count)"
    }
    
    var body: some View {
        Text(displayText)
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundColor(textColor)
            .frame(minWidth: size, minHeight: size)
            .padding(.horizontal, count > 9 ? 4 : 0)
            .background(
                Circle()
                    .fill(backgroundColor)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}

// MARK: - Icon Badge
struct IconBadge: View {
    let icon: String
    var backgroundColor: Color = Color.BBVATeal.opacity(0.15)
    var iconColor: Color = Color.BBVATeal
    var size: CGFloat = 40
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            backgroundColor,
                            backgroundColor.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(iconColor)
        }
    }
}

// MARK: - Trending Badge
struct TrendingBadge: View {
    let percentage: String
    let isPositive: Bool
    var size: TrendSize = .medium
    
    enum TrendSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 11
            case .medium: return 13
            case .large: return 15
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 10
            }
        }
    }
    
    var color: Color {
        isPositive ? Color.BBVASuccess : Color.BBVAError
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                .font(.system(size: size.iconSize, weight: .bold))
            
            Text(percentage)
                .font(.system(size: size.fontSize, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Tag Badge (for categories)
struct TagBadge: View {
    let text: String
    var color: Color = Color.BBVAPrimaryRed
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Capsule()
                            .stroke(color, lineWidth: 1.5)
                    }
                }
            )
    }
}

// MARK: - Preview
struct ModernBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                StatusBadge(text: "Activo", type: .success, icon: "checkmark.circle.fill")
                StatusBadge(text: "Pendiente", type: .warning, icon: "clock.fill")
                StatusBadge(text: "Error", type: .error, icon: "xmark.circle.fill")
            }
            
            HStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.BBVAPrimaryRed)
                    
                    NumberBadge(count: 5)
                        .offset(x: 8, y: -8)
                }
                
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.BBVAPrimaryRed)
                    
                    NumberBadge(count: 120)
                        .offset(x: 10, y: -8)
                }
            }
            
            HStack(spacing: 16) {
                IconBadge(icon: "creditcard.fill", backgroundColor: Color.BBVATeal.opacity(0.15), iconColor: Color.BBVATeal)
                IconBadge(icon: "chart.line.uptrend.xyaxis", backgroundColor: Color.BBVASuccess.opacity(0.15), iconColor: Color.BBVASuccess, size: 50)
                IconBadge(icon: "bell.fill", backgroundColor: Color.BBVAOrange.opacity(0.15), iconColor: Color.BBVAOrange, size: 45, cornerRadius: 22.5)
            }
            
            HStack(spacing: 12) {
                TrendingBadge(percentage: "+14.5%", isPositive: true)
                TrendingBadge(percentage: "-3.2%", isPositive: false)
            }
            
            HStack(spacing: 12) {
                TagBadge(text: "Finanzas", color: Color.BBVAPrimaryRed, isSelected: true)
                TagBadge(text: "Tecnología", color: Color.BBVATeal, isSelected: false)
                TagBadge(text: "Ventas", color: Color.BBVASuccess, isSelected: false)
            }
        }
        .padding()
        .background(Color.BBVABackground)
    }
}
