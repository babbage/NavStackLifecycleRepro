import SwiftUI
import UIKit

@main
struct NavStackLifecycleReproApp: App {
    init() {
        print("[APP] launched on iOS \(UIDevice.current.systemVersion)")
        if let autorun = ProcessInfo.processInfo.environment["AUTORUN_CASE"] {
            print("[APP] AUTORUN_CASE=\(autorun)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    var body: some View {
        switch ProcessInfo.processInfo.environment["AUTORUN_CASE"] {
        case "A": CaseAView()
        case "B": CaseBView()
        case "C": CaseCView()
        case "D": CaseDView()
        default: MenuView()
        }
    }
}
