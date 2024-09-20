//
//  Station.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation

public typealias StationOf<D: Dripper> = Station<D.State, D.Action>

@dynamicMemberLookup
@Observable
public final class Station<State, Action> {
    private let dripper: any Dripper<State, Action>
    var state: State

    private let _$observationRegistrar = ObservationRegistrar()

    public convenience init<D: Dripper<State, Action>>(
        initialState: State,
        dripper: D
    ) {
        self.init(state: initialState, dripper: dripper)
    }

    public convenience init<D: Dripper<State, Action>>(
        initialState: State,
        @DripperBuilder<State, Action> _ dripperBuilder: () -> D
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

    public func pour(_ action: Action) {
        dripper.drip(state, action)
    }

    public subscript<Member>(
        dynamicMember dynamicMember: WritableKeyPath<State, Member>
    ) -> Member {
        get {
            return state[keyPath: dynamicMember]
        }
        set {
            state[keyPath: dynamicMember] = newValue
        }
    }
}
