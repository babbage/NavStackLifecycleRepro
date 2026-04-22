import SwiftUI

struct DestinationA: Hashable {
    let id = UUID()
}

struct CaseAView: View {
    @State private var path = NavigationPath([DestinationA()])

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Text("CASE A ROOT")
                    .font(.largeTitle)
                Text("path pre-populated with one destination at init")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onAppear { print("[CASE_A][ROOT] onAppear") }
            .task { print("[CASE_A][ROOT] task") }
            .onFirstAppear { print("[CASE_A][ROOT] onFirstAppear") }
            .onFirstTask { print("[CASE_A][ROOT] onFirstTask") }
            .navigationDestination(for: DestinationA.self) { dest in
                VStack {
                    Text("CASE A DESTINATION")
                        .font(.title)
                    Text(dest.id.uuidString)
                        .font(.caption)
                }
                .onAppear { print("[CASE_A][DEST] onAppear — id=\(dest.id)") }
                .task { print("[CASE_A][DEST] task — id=\(dest.id)") }
            }
        }
        .onAppear { print("[CASE_A][STACK] onAppear") }
    }
}

#Preview {
    CaseAView()
}
