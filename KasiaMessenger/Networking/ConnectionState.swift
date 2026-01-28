import SwiftUI

enum ConnectionState: String {
    case disconnected
    case connecting
    case connected
    case failed

    var label: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .disconnected:
            return .gray
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .failed:
            return .red
        }
    }
}
