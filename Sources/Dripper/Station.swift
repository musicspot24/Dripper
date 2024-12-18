//
//  Station.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation

public typealias StationState = Observable & Sendable

public typealias StationOf<D: Dripper> = Station<D.State, D.Action>

// MARK: - Station

/// ``Station`` is responsible for coordinating state updates, while the actual state is managed by ``StateHandler``,
/// which is an actor that ensures thread-safe state management.
///
/// `Station` provides support for observing state changes using an `AsyncStream`. It manages a background task to
/// continuously update the state.
///
/// > Important:
/// > ``state-swift.property`` should be a class since `@Observable` is currently only available on class objects.
/// > Therefore, `State`'s shape should be as below.
/// ```swift
/// @MainActor // UI binding + conforming Sendable
/// @Observable // Observation
/// final class State {
///     var count: Int = .zero
/// }
/// ```
@MainActor
@dynamicMemberLookup
public final class Station<State: StationState, Action: Sendable>: StateYieldPolicy {

    // MARK: Properties

    public let state: StateStorage<State, Action>

    // MARK: Lifecycle

    public convenience init(
        initialState: State,
        dripper: @Sendable @autoclosure () -> some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripper())
    }

    public convenience init(
        initialState: State,
        @DripperBuilder<State, Action> _ dripperBuilder: () -> some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripperBuilder())
    }

    init<D: Dripper>(state: D.State, dripper: D) where D.State == State, D.Action == Action {
        let stateStorage = StateStorage(initialState: state, dripper: dripper)
        self.state = stateStorage
    }

    deinit { }

    // MARK: Functions

    public func pour(_ action: Action) {
        Task {
            await state.pour(action)
        }
    }

    public subscript<Member>(
        dynamicMember dynamicMember: ReferenceWritableKeyPath<StateStorage<State, Action>, Member>
    ) -> Member {
        get { state[keyPath: dynamicMember] }
        set { state[keyPath: dynamicMember] = newValue }
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension Station {
    public func bind<Member>(
        _ dynamicMember: ReferenceWritableKeyPath<StateStorage<State, Action>, Member>
    ) -> Binding<Member> {
        Binding(
            get: {
                self.state[keyPath: dynamicMember]
            },
            set: { newValue in
                self.state[keyPath: dynamicMember] = newValue
            }
        )
    }
}
#endif
