//
//  Station.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation

public typealias StationOf<D: Dripper> = Station<D.State, D.Action>

// MARK: - Station

@dynamicMemberLookup
@MainActor
public final class Station<State: Observable, Action> {

    // MARK: Properties

    var state: State

    private let dripper: any Dripper<State, Action>

    // MARK: Lifecycle

    public convenience init(
        initialState: State,
        dripper: some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripper)
    }

    public convenience init(
        initialState: State,
        @DripperBuilder<State, Action> _ dripperBuilder: () -> some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripperBuilder())
    }

    init<D: Dripper>(
        state: D.State,
        dripper: D
    ) where D.State == State, D.Action == Action {
        self.state = state
        self.dripper = dripper
    }

    // MARK: Functions

    public func pour(_ action: Action) {
        let effect = dripper.drip(state, action)
        // FIXME: Currently, side effect is called no matter it's empty or not.
        Task {
            try await effect.run { action in
                pour(action)
            }
        }
    }

    public subscript<Member>(
        dynamicMember dynamicMember: WritableKeyPath<State, Member>
    ) -> Member {
        get {
            state[keyPath: dynamicMember]
        }
        set {
            state[keyPath: dynamicMember] = newValue
        }
    }
}
