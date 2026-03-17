import SwiftUI

#if DEBUG
enum PreviewDisplayName {
    static func english(_ title: String) -> String {
        "\(title) \u{00B7} English"
    }

    static func persianRTL(_ title: String) -> String {
        "\(title) \u{00B7} Persian RTL"
    }
}
#endif
