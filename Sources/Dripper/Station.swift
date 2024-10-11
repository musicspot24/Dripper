//
//  Station.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation
import SwiftUI

public typealias StationOf<D: Dripper> = Station<D.State, D.Action>

// MARK: - Station

@dynamicMemberLookup
@MainActor
public final class Station<State: Sendable, Action: Sendable> {

    // MARK: Properties

    private var state: State
    private let dripper: any Dripper<State, Action>

    // MARK: Computed Properties

    public var currentState: State {
        state
    }

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

        if let effect {
            Task {
                await effect.blend(
                    Pour { self.pour($0) }
                )
            }
        }
    }

    public subscript<Member>(
        dynamicMember dynamicMember: ReferenceWritableKeyPath<State, Member>
    ) -> Member {
        get {
            state[keyPath: dynamicMember]
        }
        set {
            state[keyPath: dynamicMember] = newValue
        }
    }
}

extension Station where State: AnyObject {
    public func bind<Member>(
        _ dynamicMember: ReferenceWritableKeyPath<State, Member>
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
