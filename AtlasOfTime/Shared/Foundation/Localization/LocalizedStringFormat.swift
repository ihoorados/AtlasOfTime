import Foundation

enum LocalizedStringFormat {
    static func resolve(
        _ key: String,
        locale: Locale = .current,
        _ arguments: CVarArg...
    ) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, locale: locale, arguments: arguments)
    }

    static func resolve(
        _ key: String,
        locale: Locale = .current,
        comment: StaticString = "",
        _ arguments: CVarArg...
    ) -> String {
        let format = NSLocalizedString(key, comment: String(describing: comment))
        return String(format: format, locale: locale, arguments: arguments)
    }
}
