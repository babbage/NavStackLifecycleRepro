import SwiftUI

extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }

    func onFirstTask(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(OnFirstTaskModifier(action: action))
    }
}

private struct OnFirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var hasFired = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasFired else { return }
            hasFired = true
            action()
        }
    }
}

private struct OnFirstTaskModifier: ViewModifier {
    let action: @Sendable () async -> Void
    @State private var hasFired = false

    func body(content: Content) -> some View {
        content.task {
            guard !hasFired else { return }
            hasFired = true
            await action()
        }
    }
}
