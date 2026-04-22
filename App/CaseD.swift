import SwiftUI
import Observation

/// An `@Observable` that emits change notifications on a timer, simulating
/// the publisher churn a real app's view-model graph produces during the
/// first second or two after a presentation (Apollo subscriptions, GraphQL
/// watchers, BLE callbacks, firmware lifecycle observers, etc.).
@Observable
final class ChurningObservable {
    var tickCount: Int = 0
    private var timer: Timer?

    @ObservationIgnored private var emissionsPerSecond: Int = 20

    func startChurning(emissionsPerSecond: Int = 20) {
        stop()
        self.emissionsPerSecond = emissionsPerSecond
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / Double(emissionsPerSecond),
            repeats: true
        ) { [weak self] _ in
            self?.tickCount += 1
        }
        print("[CHURN] started at \(emissionsPerSecond) Hz")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

struct DestinationD: Hashable {
    let id = UUID()
}

struct CaseDView: View {
    /// Shared via `.environment(_:)` so BOTH the outer view and the
    /// covered NavigationStack's root observe the same churn — mirroring the
    /// real app where `LinkedBoardViewModel` is an `@Environment` dependency
    /// of both `HomeTabContent` (presenter) and `ConnectToPanelRootView`
    /// (cover content).
    @State private var churn = ChurningObservable()
    @State private var showCover = false

    var body: some View {
        // Reading `churn.tickCount` here makes this body dependent on the
        // churning Observable, so every emission forces a re-render of this
        // view — including the .fullScreenCover modifier and its content.
        let _ = churn.tickCount

        NavigationStack {
            VStack(spacing: 16) {
                Text("CASE D OUTER")
                    .font(.title)
                Text("Parent AND cover content both observe a churning " +
                     "@Observable. Cover root is a Color primitive. " +
                     "Ticks: \(churn.tickCount)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                Button("Present fullScreenCover") {
                    showCover = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .fullScreenCover(isPresented: $showCover) {
                CoveredColorRootStack()
                    .environment(churn)
            }
            .onAppear {
                print("[CASE_D][OUTER] onAppear — starting churn")
                let rate = Int(ProcessInfo.processInfo.environment["CHURN_HZ"] ?? "200") ?? 200
                churn.startChurning(emissionsPerSecond: rate)
                if ProcessInfo.processInfo.environment["AUTORUN_CASE"] == "D" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCover = true
                    }
                }
            }
        }
    }
}

/// Mirrors the real app's `ConnectToPanelRootView.body`: a `Color` primitive
/// as the NavigationStack root, `path` pre-populated with one destination at
/// init, all four lifecycle modifiers attached.
private struct CoveredColorRootStack: View {
    /// Shares the parent's churning Observable — when it emits, THIS view's
    /// body also recomputes. Matches the real app where both the presenter
    /// and `ConnectToPanelRootView` observe `LinkedBoardViewModel` via
    /// `@Environment`.
    @Environment(ChurningObservable.self) private var churn
    @State private var path = NavigationPath([DestinationD()])

    var body: some View {
        // Touch the observable so SwiftUI records this view's dependency.
        let _ = churn.tickCount

        NavigationStack(path: $path) {
            Color.blue
                .onAppear { print("[CASE_D][ROOT] onAppear") }
                .task { print("[CASE_D][ROOT] task") }
                .onFirstAppear { print("[CASE_D][ROOT] onFirstAppear") }
                .onFirstTask { print("[CASE_D][ROOT] onFirstTask") }
                .navigationDestination(for: DestinationD.self) { dest in
                    VStack {
                        Text("CASE D DESTINATION")
                            .font(.title)
                        Text(dest.id.uuidString)
                            .font(.caption)
                    }
                    .onAppear { print("[CASE_D][DEST] onAppear — id=\(dest.id)") }
                    .task { print("[CASE_D][DEST] task — id=\(dest.id)") }
                }
        }
        .onAppear { print("[CASE_D][STACK] onAppear") }
    }
}

#Preview {
    CaseDView()
}
