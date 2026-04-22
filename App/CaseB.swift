import SwiftUI

struct DestinationB: Hashable {
    let id = UUID()
}

struct CaseBView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Text("CASE B ROOT")
                    .font(.largeTitle)
                Text("path starts empty, pushes DestinationB from .task")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onAppear { print("[CASE_B][ROOT] onAppear") }
            .task {
                print("[CASE_B][ROOT] task — pushing destination")
                path.append(DestinationB())
            }
            .onFirstAppear { print("[CASE_B][ROOT] onFirstAppear") }
            .onFirstTask { print("[CASE_B][ROOT] onFirstTask") }
            .navigationDestination(for: DestinationB.self) { dest in
                VStack {
                    Text("CASE B DESTINATION")
                        .font(.title)
                    Text(dest.id.uuidString)
                        .font(.caption)
                }
                .onAppear { print("[CASE_B][DEST] onAppear — id=\(dest.id)") }
                .task { print("[CASE_B][DEST] task — id=\(dest.id)") }
            }
        }
        .onAppear { print("[CASE_B][STACK] onAppear") }
    }
}

#Preview {
    CaseBView()
}
