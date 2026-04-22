# NavStackLifecycleRepro

Minimal SwiftUI repro for investigating a reported iOS 26 `NavigationStack`
lifecycle anomaly observed in a Basis Home production build.

## Hypothesis

When a `NavigationStack` is initialised with a non-empty `path` binding,
its root view's `.onAppear` / `.task` / custom `.onFirstAppear` /
`.onFirstTask` modifiers do not fire on iOS 26. (The root view is never
shown because the stack lands directly on the pre-populated destination.)

The Basis Home codebase relies on root-view `.onFirstAppear` to inject
`backendService` into `ConnectToPanelViewModel`. A customer on iOS 26.4.1
reported `failedToAuthenticate` on every panel-select tap; logs show
the `.onFirstAppear` injection message is absent across all three sessions.

## Test matrix

Two scenarios are exercised:

| Case | Initial `path` | Notes |
| ---- | -------------- | ----- |
| A    | `NavigationPath([DestinationA()])` | Pre-populated at init |
| B    | empty, then `path.append(DestinationB())` from `.task` | Control |

Each case's root view attaches all four lifecycle modifiers and logs
tagged messages. `UIDevice.current.systemVersion` is printed at launch.

## Running locally

Select a scenario via env var on the scheme, or auto-cycle from the
menu. To drive from the CLI:

```sh
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl install booted path/to/NavStackLifecycleRepro.app
SIMCTL_CHILD_AUTORUN_CASE=A \
  xcrun simctl launch --console-pty booted \
  com.duncanbabbage.NavStackLifecycleRepro
```

`AUTORUN_CASE` values: `A`, `B`, or unset (shows menu).

## Why CI

Developers on macOS 26 cannot run Xcode 16.4 locally — macOS 26.2+
blocks older Xcodes from launching. Basis's production Home 1.10.2 IPA
was built with Xcode 16.4, so the iOS-18-SDK-linked variant of this
repro must be built in CI.

`.github/workflows/build.yml` builds the sample with Xcode 16.4 on a
`macos-15` runner and uploads the `.app` as an artifact. Install that
onto a local iOS 26.4 simulator to test whether root-view lifecycle
modifiers fire in the Xcode-16.4-SDK-linked build.

Compare against the Xcode-26.4-SDK-linked build (built locally on macOS
26) which is known to fire all root lifecycle modifiers on iOS 26.4.
