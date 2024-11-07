# ☕ Dripper

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmusicspot24%2FDripper%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/musicspot24/Dripper)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmusicspot24%2FDripper%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/musicspot24/Dripper)

**Dripper** is an architecture framework for SwiftUI project.\
It's a lightweight framework focusing on a very core concepts of [Swift-Composable-Architecture](https://github.com/pointfreeco/swift-composable-architecture) from Point-Free.

These are the core concepts we needed:
1. Contravariance usage of micro-states/actions within its parent state/action. ❌
2. Unidirectional mutation flow for concise state handling. ✅
3. Simple to divide responsibility, simple to unit-test. 🏗️

## What's the difference from TCA?

We wanted to use the native Swift feature as much as possible, so we decided to use `@Observable` instead of using custom observation mechanism like `@ObservableState` in TCA.\
Sadly, this means that we can't use solid struct-based state management because of the limitation of `@Observable`.\
`@Observable` currently only supports class-based properties, so we had to use class for our `State`.\
Once Swift supports class-based properties, we will consider migrating to struct-based (or actor-based) state management.


## How to use?

It's basically similar to the original TCA, but with a little bit of simplification.\
Here's a simple example:

### Dripper
First, we have to create a `Dripper` struct that conforms to `Dripper` protocol.\
It has a role equivalent to `Reducer` in TCA.
```swift
import Dripper

struct Counter: Dripper {
    @Observable
    final class State: @unchecked Sendable {
        var count = 0
        @ObservationIgnored private let id: UUID

        init(count: Int = .zero) {
            self.count = count
            self.id = UUID()
        }
    }

    enum Action {
        case increase
        case decrease
    }

    var body: some Dripper<State, Action> {
        Drip { state, action in
            switch action {
            case .increase:
                state.count += 1
                return .none

            case .decrease:
                state.count -= 1
                return .none
            }
        }
    }
}
```

> [!NOTE]
> `State` class should be annotated with `@unchecked Sendable` to suppress the compiler error.\
> This is because `State` actually cannot be `Sendable` standalone.\
> However, while using `State` within `Station`, it's guaranteed to be thread-safe because it is managed by actor called `StateHandler`.
>
> We'll find some workaround for this in the future.

### Station
In SwiftUI view, you can use `Dripper` by using `Station` that uses `Dripper` as its Generic type.

```swift
import SwiftUI
import Dripper

struct ContentView: View {
    let station: StationOf<Counter>
}

#Preview {
    CounterView(
        station: Station(initialState: Counter.State()) {
            Counter()
        }

        Button("\(station.count)") {
            station.pour(.increase)
        }
    )
}

You can trigger `Action` with `pour` method, and you can observe the state with just accessing the property of `station`.

### Effects

You can use `Effect` to handle side-effects like async operation.\
Actually, `.none` you saw in the `Dripper` section is one of `Effect` which is meaning there's no side-effect.

Here's an example of how to use `Effect`:

```swift
import Dripper

var body: some Dripper<State, Action> {
    Drip { state, action in
        switch action {
        case .increase:
            state.count += 1
            return .none // means no side-effect

        case .decrease:
            state.count -= 1
            return .run { pour in // means there's a side-effect
                let score = try await fetchScore(for: .now)

                let action = score.isPositive ? Action.increase : Action.decrease
                pour(action) // you can trigger another action
            }
        }
    }
}
```

You can use `.run` to handle side-effect.\
It takes a closure that takes `pour` as an argument.\
You can trigger another action by calling `pour` inside the closure.
