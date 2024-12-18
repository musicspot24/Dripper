//
//  StateStorage.swift
//  Dripper
//
//  Created by 이창준 on 10/10/24.
//

import Foundation
import OSLog

// MARK: - StateHandler

/// `StateActor` is an actor class responsible for managing `State` in a thread-safe manner.
///
/// `StateActor` maintains the state, processes actions, and manages side-effects by coordinating with a `Dripper` to yield
/// updated state values asynchronously.
///
/// `StateActor` encapsulates state modifications, ensuring data race safety by using isolated actor environment. \
/// It also provides an asynchronous stream (`AsyncStream`) for any listener outside actor that is interested in state changes,
/// and handles asynchronous side-effects using `Task` objects.
///
/// ## Generic Parameters
/// - `State`: The type that represents the state, must conform to `Sendable` to allow safe concurrent access.
/// - `Action`: The type that represents actions that can be dispatched, must conform to `Sendable` to allow safe concurrent access.
@dynamicMemberLookup
public actor StateStorage<State: Sendable, Action: Sendable>: StateYieldPolicy {

    // MARK: Properties

    let continuation: AsyncStream<State>.Continuation

    /// Asynchronous stream which yields `State`.
    private(set) var stream: AsyncStream<State>

    private let dripper: any Dripper<State, Action>

    private var tasks: [UUID: Task<Void, Never>] = [:]

    /// Source of `State` managed by this actor.
    /// It also yields new
    @MainActor private var state: State

    // MARK: Lifecycle

    init(initialState state: State, dripper: some Dripper<State, Action>) {
        self.state = state
        self.dripper = dripper

        let (stream, continuation) = AsyncStream<State>.makeStream()
        self.stream = stream
        self.continuation = continuation
    }

    deinit {
        for task in tasks { task.value.cancel() }
        continuation.finish()
    }

    // MARK: Functions

    @MainActor
    public subscript<Member>(
        dynamicMember dynamicMember: ReferenceWritableKeyPath<State, Member> & Sendable
    ) -> Member {
        get { state[keyPath: dynamicMember] }
        set {
            state[keyPath: dynamicMember] = newValue
            continuation.yield(state)
        }
    }

    func pour(_ action: Action) async {
        let taskID = UUID()
//        let oldState = state
        let effect = await dripper.drip(state, action)
        // FIXME: Only yield on continuation when state has changed.
        // Since `State` is a class, we can't know if it's changed or not by simply
        // copying and comparing them.
//        if shouldYield(oldValue: oldState, newValue: state) {
        await continuation.yield(state)
//        }

        if let effect { // Side-Effect occurred
            let task = Task { [weak self, taskID] in
                guard let self else { return }
                let pour = Pour { action in
                    Task {
                        await self.pour(action)
                    }
                }
                await effect.blend(pour)
                await self.removeTask(taskID)
            }

            tasks.updateValue(task, forKey: taskID)
        }
    }

    private func removeTask(_ key: UUID) {
        if let task = tasks.removeValue(forKey: key) {
            task.cancel()
        }
    }

}
