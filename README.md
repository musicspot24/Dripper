# ☕ Dripper

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmusicspot24%2FDripper%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/CoffeeLog/Dripper)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmusicspot24%2FDripper%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/CoffeeLog/Dripper)

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
> You need to add `@unchecked Sendable` to the `State` class to suppress compiler errors.
> While `State` itself is actually not thread-safe, when used within `Station`, it is guaranteed to be thread-safe since it's managed by the `StateHandler` actor.
>
> We'll implement a better solution for this in a future update.
> Also, feel free to suggest any improvements on this issue! 😊

### Station
To use `Dripper` in your SwiftUI views, create a `Station` instance with `Dripper` as its generic type parameter.

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
```

You can trigger `Action` using the `pour` method and directly access state through the `Station` properties.

### Effects

`Effect` helps you handle side-effects such as asynchronous operations.\
Remember the `.none` we saw in the `Dripper` example?\
Actually, that's one of `Effect` that indicates no side-effects will occur.

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

To handle side-effects, use `.run` with a closure that receives a `pour` function.\
Inside this closure, you can trigger additional actions by calling `pour` with desired `Action` as parameter.

---
Thanks for checking out Dripper! Questions and contributions are always welcome 😊

MIT license - [LICENSE](https://github.com/musicspot24/Dripper?tab=MIT-1-ov-file#)
