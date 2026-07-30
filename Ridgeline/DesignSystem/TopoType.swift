import SwiftUI

/// Copperplate titles and SF Mono readouts.
public enum TopoType {
    public static func title(_ size: CGFloat = 22, relativeTo textStyle: Font.TextStyle = .title3) -> Font {
        .custom("Copperplate", size: size, relativeTo: textStyle)
    }

    public static func body(_ size: CGFloat = 15, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    public static func bodyBold(_ size: CGFloat = 15, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    public static func mono(_ size: CGFloat = 14, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    public static func monoBold(_ size: CGFloat = 18, relativeTo textStyle: Font.TextStyle = .title3) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }

    public static func badge(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}
