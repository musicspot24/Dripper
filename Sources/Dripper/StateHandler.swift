//
//  StateHandler.swift
//  Dripper
//
//  Created by 이창준 on 10/10/24.
//

import Foundation

// MARK: - StateYieldPolicy

private protocol StateYieldPolicy {
    associatedtype State
    func shouldYield(oldValue: State, newValue: State) -> Bool
}

extension StateYieldPolicy {
    fileprivate func shouldYield(oldValue _: State, newValue _: State) -> Bool {
        true
    }
}

extension StateYieldPolicy where State: Equatable {
    fileprivate func shouldYield(oldValue: State, newValue: State) -> Bool {
        oldValue != newValue
    }
}

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
actor StateHandler<State: Sendable, Action: Sendable>: StateYieldPolicy {

    // MARK: Properties

    let continuation: AsyncStream<State>.Continuation

    /// Asynchronous stream which yields `State`.
    private(set) var stream: AsyncStream<State>

    private let dripper: any Dripper<State, Action>

    private var tasks: [UUID: Task<Void, Never>] = [:]

    // MARK: Computed Properties

    /// Source of `State` managed by this actor.
    /// It also yields new
    private var state: State {
        didSet {
            if shouldYield(oldValue: oldValue, newValue: state) {
                continuation.yield(state)
            }
        }
    }

    // MARK: Lifecycle

    init(initialState: State, dripper: some Dripper<State, Action>) {
        self.state = initialState
        self.dripper = dripper

        (self.stream, continuation) = AsyncStream<State>.makeStream()
    }

    deinit {
        for task in tasks { task.value.cancel() }
    }

    // MARK: Functions

    subscript<Member>(
        dynamicMember dynamicMember: ReferenceWritableKeyPath<State, Member> & Sendable
    ) -> Member {
        get { state[keyPath: dynamicMember] }
        set { state[keyPath: dynamicMember] = newValue }
    }

    func pour(_ action: Action) async {
        let taskID = UUID()
        let effect = await dripper.drip(state, action)

        if let effect { // Side-Effect occurred
            let task = Task { [weak self, taskID] in
                guard let self else { return }
                let pour = await Pour { action in
                    Task {
                        await self.pour(action)
                    }
                }
                await effect.blend(pour)
                await self.removeTask(taskID)
            }

            await updateTask(task, forKey: taskID)
        }
    }

    private func updateTask(_ task: Task<Void, Never>, forKey key: UUID) {
        tasks.updateValue(task, forKey: key)
    }

    private func removeTask(_ key: UUID) {
        if let task = tasks.removeValue(forKey: key) {
            task.cancel()
        }
    }

}
