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

    /// The current state of the station.
    ///
    /// Since ``Dripper/Dripper/State`` is a class type, it's referenced by both ``Station`` and ``StateHandler``.
    public private(set) var state: State

    private let stateHandler: StateHandler<State, Action>

    private let continuation: AsyncStream<State>.Continuation
    private var task: Task<Void, Never>?

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
        self.state = state

        let stateHandler = StateHandler(initialState: state, dripper: dripper)
        self.stateHandler = stateHandler
        self.continuation = stateHandler.continuation

        // Update `state` as `StateHandler`'s `state` is updated.
        self.task = Task { @MainActor [weak self] in
            guard let stateStream = await self?.stateHandler.stream else { return }
            for await state in stateStream {
                guard let self else { break }
                self.state = state
            }
        }
    }

    deinit {
        task?.cancel()
        // Continuation is finished on `StateHandler`
    }

    // MARK: Functions

    public func pour(_ action: Action) {
        Task {
            await stateHandler.pour(action)
        }
    }

    public subscript<Member>(
        dynamicMember dynamicMember: ReferenceWritableKeyPath<State, Member>
    ) -> Member {
        get { state[keyPath: dynamicMember] }
        set {
            state[keyPath: dynamicMember] = newValue
            continuation.yield(state)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension Station {
    public func bind<Member>(
        _ dynamicMember: ReferenceWritableKeyPath<State, Member>
    ) -> Binding<Member> {
        Binding(
            get: { self.state[keyPath: dynamicMember] },
            set: { newValue in
                self.state[keyPath: dynamicMember] = newValue
                self.continuation.yield(self.state)
            }
        )
    }
}
#endif
