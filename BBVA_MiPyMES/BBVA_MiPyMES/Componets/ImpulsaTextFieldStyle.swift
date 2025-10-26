

import SwiftUI

// MARK: - Primary TextField Style with Modern Design
struct ImpulsaTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium))
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.BBVALightGray, lineWidth: 1.5)
            )
            .foregroundColor(Color.BBVATextPrimary)
    }
}

// MARK: - Focused TextField Style (with animated border)
struct ImpulsaFocusedTextFieldStyle: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var icon: String? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isFocused ? Color.BBVAPrimaryRed : Color.BBVAMediumGray)
                    .frame(width: 24)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                }
            }
            .font(.system(size: 16, weight: .medium))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(
                    color: isFocused ? Color.BBVAPrimaryRed.opacity(0.15) : Color.black.opacity(0.05),
                    radius: isFocused ? 12 : 8,
                    x: 0,
                    y: isFocused ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.BBVAPrimaryRed, Color.BBVADarkRed]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.BBVALightGray, Color.BBVALightGray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                    lineWidth: isFocused ? 2 : 1.5
                )
        )
        .foregroundColor(Color.BBVATextPrimary)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Search TextField Style with Icon
struct ImpulsaSearchFieldStyle: View {
    @Binding var text: String
    var placeholder: String = "Buscar..."
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color.BBVAPrimaryRed : Color.BBVAMediumGray)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.BBVATextPrimary)
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.BBVAMediumGray)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isFocused ? Color.white : Color.BBVALightGray)
                .shadow(
                    color: isFocused ? Color.BBVAPrimaryRed.opacity(0.1) : Color.clear,
                    radius: isFocused ? 10 : 0,
                    x: 0,
                    y: isFocused ? 4 : 0
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Color.BBVAPrimaryRed.opacity(0.3) : Color.clear,
                    lineWidth: isFocused ? 1.5 : 0
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text.isEmpty)
    }
}

// MARK: - Floating Label TextField Style
struct ImpulsaFloatingLabelTextField: View {
    @Binding var text: String
    var label: String
    var isSecure: Bool = false
    var icon: String? = nil
    @FocusState private var isFocused: Bool
    
    private var shouldFloat: Bool {
        isFocused || !text.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Floating label
            Text(label)
                .font(.system(size: shouldFloat ? 12 : 16, weight: .medium))
                .foregroundColor(isFocused ? Color.BBVAPrimaryRed : Color.BBVAMediumGray)
                .offset(x: icon != nil ? 36 : 18, y: shouldFloat ? -28 : 0)
                .scaleEffect(shouldFloat ? 1.0 : 1.0, anchor: .leading)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: shouldFloat)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isFocused ? Color.BBVAPrimaryRed : Color.BBVAMediumGray)
                        .frame(width: 24)
                }
                
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .opacity(shouldFloat ? 1 : 0)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(
                        color: isFocused ? Color.BBVAPrimaryRed.opacity(0.15) : Color.black.opacity(0.05),
                        radius: isFocused ? 12 : 8,
                        x: 0,
                        y: isFocused ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isFocused ? 
                            LinearGradient(
                                gradient: Gradient(colors: [Color.BBVAPrimaryRed, Color.BBVADarkRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [Color.BBVALightGray, Color.BBVALightGray]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                        lineWidth: isFocused ? 2 : 1.5
                    )
            )
            .foregroundColor(Color.BBVATextPrimary)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func impulsaTextField() -> some View {
        self.textFieldStyle(ImpulsaTextFieldStyle())
    }
}
