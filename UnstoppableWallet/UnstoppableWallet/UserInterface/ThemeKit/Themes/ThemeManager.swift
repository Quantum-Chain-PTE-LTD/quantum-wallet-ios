import Combine
import HsExtensions
import SwiftUI
import UIKit

public class ThemeManager {
    // Quantum Wallet is dark-only. Mirrors Android c13a915e which locks ThemeService to dark.
    private static let defaultLightMode: ThemeMode = .dark
    private static let userDefaultsKey = "theme_mode"

    public static var shared = ThemeManager()

    @PostPublished public var themeMode: ThemeMode {
        didSet {
            if themeMode != .dark {
                themeMode = .dark
                return
            }
            UserDefaults.standard.set(themeMode.rawValue, forKey: ThemeManager.userDefaultsKey)
            currentTheme = ThemeManager.theme(mode: themeMode)
            Theme.updateNavigationBarTheme()
        }
    }

    private(set) var currentTheme: ITheme

    init() {
        // Always dark for Quantum Wallet; drop any legacy stored preference.
        UserDefaults.standard.set(nil, forKey: "light_mode")
        UserDefaults.standard.set(ThemeMode.dark.rawValue, forKey: ThemeManager.userDefaultsKey)

        currentTheme = ThemeManager.theme(mode: .dark)
        themeMode = .dark
    }

    private static func theme(mode: ThemeMode) -> ITheme {
        switch mode {
        case .light: return LightTheme()
        case .dark: return DarkTheme()
        case .system: return SystemTheme()
        }
    }
}

public class Theme {
    public static var current: ITheme {
        ThemeManager.shared.currentTheme
    }

    public static func updateNavigationBarTheme() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundColor = .themeNavigationBarBackground
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.themeLeah, .font: UIFont.headline2]
        standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.themeLeah, .font: UIFont.title2]

        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = standardAppearance
    }
}

public enum ThemeMode: String {
    case light
    case dark
    case system

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
