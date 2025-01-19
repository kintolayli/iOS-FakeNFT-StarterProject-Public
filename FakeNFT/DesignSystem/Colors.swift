import UIKit

extension UIColor {

    // MARK: - Creates color from a hex string
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }

    // TODO: - Разобраться с повторяющимися цветами после мерджа


    // MARK: - Background Colors
    static let background = UIColor { $0.userInterfaceStyle == .dark ? .ypBlackUniversal : .ypWhiteUniversal }

    // MARK: - Text Colors
    static let textPrimary: UIColor = .ypBlack
    static let primary = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0)

    static let textSecondary: UIColor = .ypGreenUniversal
    static let secondary = UIColor(red: 255 / 255, green: 193 / 255, blue: 7 / 255, alpha: 1.0)

    static let textOnPrimary = UIColor.white
    static let textOnSecondary = UIColor.black

    // MARK: - Base Colors

    static let ypGreyUniversal = UIColor(hexString: "#625C5C")
    static let ypRedUniversal = UIColor(hexString: "#F56B6C")
    static let ypBackgroundUniversal = UIColor(hexString: "#1A1B22")
    static let ypGreenUniversal = UIColor(hexString: "#1C9F00")
    static let ypBlueUniversal = UIColor(hexString: "#0A84FF")
    static let ypBlackUniversal = UIColor(hexString: "#1A1B22")
    static let ypWhiteUniversal = UIColor(hexString: "#FFFFFF")
    static let ypYellowUniversal = UIColor(hexString: "#FEEF0D")

    // MARK: - Base Colors Day/Night
    private static let ypLightGreyDay = UIColor(hexString: "#F7F7F8")
    private static let yaLightGrayLight = UIColor(hexString: "#F7F7F8")

    private static let ypLightGreyNight = UIColor(hexString: "#2C2C2E")
    private static let yaLightGrayDark = UIColor(hexString: "#2C2C2E")

    private static let yaBlackLight = UIColor(hexString: "1A1B22")
    private static let yaBlackDark = UIColor.white

    static let ypWhite = UIColor { $0.userInterfaceStyle == .dark ? .ypBlackUniversal : .ypWhiteUniversal }

    static let ypBlack = UIColor { $0.userInterfaceStyle == .dark ? .ypWhiteUniversal : .ypBlackUniversal }

    static let ypLightGrey = UIColor { $0.userInterfaceStyle == .dark ? .ypLightGreyNight : .ypLightGreyDay }

    static let ypSegmentActive = UIColor { $0.userInterfaceStyle == .dark ? .ypBlackUniversal : .ypWhiteUniversal }
    static let segmentActive = UIColor { traits in
        return traits.userInterfaceStyle == .dark
        ? .yaBlackDark
        : .yaBlackLight
    }

    static let ypSegmentInactive = UIColor { $0.userInterfaceStyle == .dark ? .ypLightGreyDay : .ypLightGreyNight }
    static let segmentInactive = UIColor { traits in
        return traits.userInterfaceStyle == .dark
        ? .yaLightGrayDark
        : .yaLightGrayLight
    }

    static let ypCloseButton = UIColor { $0.userInterfaceStyle == .dark ? .ypBlackUniversal : .ypWhiteUniversal }
}
