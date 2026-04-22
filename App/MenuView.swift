import SwiftUI

enum Scenario: String, CaseIterable, Identifiable {
    case prePopulated = "Case A: NavigationStack init with non-empty path"
    case emptyThenPush = "Case B: Empty path, push from .task"
    case fullScreenCover = "Case C: fullScreenCover wrapping Case A"
    var id: String { rawValue }
}

struct MenuView: View {
    @State private var active: Scenario?

    var body: some View {
        if let active {
            Group {
                switch active {
                case .prePopulated:
                    CaseAView()
                case .emptyThenPush:
                    CaseBView()
                case .fullScreenCover:
                    CaseCView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button("Back to menu") { self.active = nil }
                    .padding()
            }
        } else {
            NavigationStack {
                List {
                    Section("Scenarios") {
                        ForEach(Scenario.allCases) { scenario in
                            Button(scenario.rawValue) {
                                print("---- Selected: \(scenario.rawValue) ----")
                                active = scenario
                            }
                        }
                    }
                    Section("Notes") {
                        Text("Launch on iOS 18.6 then iOS 26.4 simulator. "
                           + "For each case, watch which [ROOT] log lines fire. "
                           + "Hypothesis: in Case A on iOS 26, none of the root's "
                           + ".onAppear / .task / .onFirstAppear / .onFirstTask fire.")
                            .font(.footnote)
                    }
                }
                .navigationTitle("NavStack Lifecycle")
            }
        }
    }
}

#Preview {
    MenuView()
}
