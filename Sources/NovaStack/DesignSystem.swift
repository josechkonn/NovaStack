import SwiftUI
import AppKit

// MARK: - NovaStack Design System (CleanMyMac 5 Inspired)
public enum NovaTheme {
    // Cosmic Background Palette
    public static let bgDeepMidnight = Color(red: 0.05, green: 0.06, blue: 0.14)  // #0D0F24
    public static let bgRoyalIndigo  = Color(red: 0.13, green: 0.08, blue: 0.28)  // #211447
    public static let bgCosmicPlum   = Color(red: 0.20, green: 0.05, blue: 0.32)  // #330D52
    public static let bgAccentGlow   = Color(red: 0.50, green: 0.16, blue: 0.90)  // #8029E6
    
    // Vibrant Neon Accents
    public static let neonCyan       = Color(red: 0.00, green: 0.84, blue: 1.00)  // #00D6FF
    public static let electricIndigo = Color(red: 0.45, green: 0.35, blue: 1.00)  // #7359FF
    public static let magentaPulse   = Color(red: 0.88, green: 0.18, blue: 0.80)  // #E02ECC
    public static let emeraldGreen   = Color(red: 0.12, green: 0.88, blue: 0.55)  // #1FE08C
    public static let solarAmber     = Color(red: 1.00, green: 0.72, blue: 0.18)  // #FFB82E
    public static let coralRed       = Color(red: 1.00, green: 0.32, blue: 0.42)  // #FF526B

    // Glassmorphic Surfaces
    public static let glassFill      = Color.white.opacity(0.07)
    public static let glassSelected  = Color.white.opacity(0.16)
    public static let glassHover     = Color.white.opacity(0.10)
    public static let glassBorder    = Color.white.opacity(0.13)
    public static let glassBorderSelected = Color.white.opacity(0.28)
    
    // Text Hierarchy Tokens
    public static let textPrimary    = Color.white
    public static let textSecondary  = Color.white.opacity(0.70)
    public static let textTertiary   = Color.white.opacity(0.42)

    // Master Action Button Gradients
    public static let actionGradientPrimary = LinearGradient(
        colors: [neonCyan, electricIndigo, magentaPulse],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static let actionGradientStop = LinearGradient(
        colors: [coralRed, Color(red: 0.8, green: 0.1, blue: 0.3)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Full Canvas Mesh Gradient
public struct CosmicCanvasBackground: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Base Linear Gradient
            LinearGradient(
                colors: [
                    NovaTheme.bgDeepMidnight,
                    NovaTheme.bgRoyalIndigo,
                    NovaTheme.bgCosmicPlum
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Radial Glow Top-Right (Electric Violet)
            RadialGradient(
                colors: [NovaTheme.bgAccentGlow.opacity(0.45), Color.clear],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 650
            )

            // Radial Glow Bottom-Center (Neon Cyan)
            RadialGradient(
                colors: [NovaTheme.neonCyan.opacity(0.20), Color.clear],
                center: .bottom,
                startRadius: 30,
                endRadius: 500
            )

            // Soft Center Vignette
            RadialGradient(
                colors: [NovaTheme.magentaPulse.opacity(0.12), Color.clear],
                center: .center,
                startRadius: 10,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Brand Logo View
public struct BrandLogoView: View {
    public let size: CGFloat
    
    public init(size: CGFloat = 34) {
        self.size = size
    }
    
    public var body: some View {
        Group {
            if let img = loadAppIcon() {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .shadow(color: NovaTheme.neonCyan.opacity(0.35), radius: size * 0.2, y: size * 0.08)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .fill(NovaTheme.actionGradientPrimary)
                    Image(systemName: "server.rack")
                        .font(.system(size: size * 0.45, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: size, height: size)
            }
        }
    }
    
    private func loadAppIcon() -> NSImage? {
        let paths = [
            "/Applications/NovaStack.app/Contents/Resources/AppIcon.png",
            "/Users/josechacon/.gemini/antigravity/scratch/NovaStack/Resources/AppIcon.png",
            "/Users/josechacon/.gemini/antigravity/brain/3a8c3d77-d053-4271-b92e-e8184b777d01/clean_logo_transparent.png"
        ]
        for path in paths {
            if FileManager.default.fileExists(atPath: path),
               let image = NSImage(contentsOfFile: path) {
                return image
            }
        }
        return NSImage(named: NSImage.applicationIconName)
    }
}

// MARK: - Glass Card Modifier
public struct GlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 16
    public var isSelected: Bool = false
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? NovaTheme.glassSelected : NovaTheme.glassFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? NovaTheme.glassBorderSelected : NovaTheme.glassBorder,
                        lineWidth: isSelected ? 1.0 : 0.5
                    )
            )
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 16, isSelected: Bool = false) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, isSelected: isSelected))
    }
}

// MARK: - Status Dot Indicator
public struct StatusDot: View {
    public let isActive: Bool
    public var activeColor: Color = NovaTheme.emeraldGreen
    public var inactiveColor: Color = Color.white.opacity(0.25)
    public var size: CGFloat = 8
    
    public init(isActive: Bool, activeColor: Color = NovaTheme.emeraldGreen, inactiveColor: Color = Color.white.opacity(0.25), size: CGFloat = 8) {
        self.isActive = isActive
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(activeColor.opacity(0.40))
                    .frame(width: size * 2.0, height: size * 2.0)
            }
            Circle()
                .fill(isActive ? activeColor : inactiveColor)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Compact Badge Pill
public struct NovaBadge: View {
    public let text: String
    public var icon: String? = nil
    public var color: Color = .white
    
    public init(_ text: String, icon: String? = nil, color: Color = .white) {
        self.text = text
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.16))
        .clipShape(Capsule())
    }
}
