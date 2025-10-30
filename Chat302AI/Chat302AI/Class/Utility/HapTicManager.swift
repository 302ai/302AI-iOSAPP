//
//  HapTicManager.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/28.
//

import SwiftUI


// 震动样式枚举
enum HapticStyle {
    case light, medium, heavy, soft, rigid
    case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

// 震动 Modifier
struct HapticFeedback: ViewModifier {
    let style: HapticStyle
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _ in
                playHaptic(style: style)
            }
    }
    
    private func playHaptic(style: HapticStyle) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

// View 扩展
extension View {
    func hapticFeedback(_ style: HapticStyle, trigger: Bool) -> some View {
        self.modifier(HapticFeedback(style: style, trigger: trigger))
    }
}

class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func play(_ style: HapticStyle) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}
