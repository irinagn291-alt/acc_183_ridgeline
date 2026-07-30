import SwiftUI

/// Ordnance Survey topo colours for Ridgeline.
public enum RidgePalette {
    /// Map ground.
    public static let ground = Color(hex: 0x16211C)
    /// Contour line green.
    public static let contours = Color(hex: 0x3A5147)
    /// Paper cream for labels and fills.
    public static let cream = Color(hex: 0xDDE3D6)
    /// Summit marker orange.
    public static let summit = Color(hex: 0xC86B2B)

    public static let creamDim = cream.opacity(0.72)
    public static let creamFaint = cream.opacity(0.42)
    public static let contourDim = contours.opacity(0.55)

    public static let inventory: [(name: String, color: Color)] = [
        ("ground", ground),
        ("contours", contours),
        ("contour dim", contourDim),
        ("cream", cream),
        ("cream dim", creamDim),
        ("cream faint", creamFaint),
        ("summit", summit)
    ]
}

extension Color {
    /// Builds a colour from a packed `0xRRGGBB` literal.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
