import SwiftUI

struct DestinationC: Hashable {
    let id = UUID()
}

struct CaseCView: View {
    @State private var showCover = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("CASE C OUTER")
                    .font(.title)
                Text("Analogue of HomeUnlinkedView — presents the stack via .fullScreenCover")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                Button("Present fullScreenCover") {
                    showCover = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .fullScreenCover(isPresented: $showCover) {
                CoveredNavStackView()
            }
            .onAppear {
                print("[CASE_C][OUTER] onAppear")
                if ProcessInfo.processInfo.environment["AUTORUN_CASE"] == "C" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCover = true
                    }
                }
            }
        }
    }
}

private struct CoveredNavStackView: View {
    @State private var path = NavigationPath([DestinationC()])

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Text("CASE C ROOT")
                    .font(.largeTitle)
                Text("Inside fullScreenCover. path pre-populated with one destination at init.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onAppear { print("[CASE_C][ROOT] onAppear") }
            .task { print("[CASE_C][ROOT] task") }
            .onFirstAppear { print("[CASE_C][ROOT] onFirstAppear") }
            .onFirstTask { print("[CASE_C][ROOT] onFirstTask") }
            .navigationDestination(for: DestinationC.self) { dest in
                VStack {
                    Text("CASE C DESTINATION")
                        .font(.title)
                    Text(dest.id.uuidString)
                        .font(.caption)
                }
                .onAppear { print("[CASE_C][DEST] onAppear — id=\(dest.id)") }
                .task { print("[CASE_C][DEST] task — id=\(dest.id)") }
            }
        }
        .onAppear { print("[CASE_C][STACK] onAppear") }
    }
}

#Preview {
    CaseCView()
}
