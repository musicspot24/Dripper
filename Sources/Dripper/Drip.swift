//
//  Drip.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

public struct Drip<State, Action>: Dripper {
    @usableFromInline
    let drip: (State, Action) -> State

    @usableFromInline
    init(
        internal drip: @escaping (State, Action) -> State
    ) {
        self.drip = drip
    }

    @inlinable
    public init(_ drip: @escaping (_ state: State, _ action: Action) -> State) {
        self.init(internal: drip)
    }

    public init(_ dripper: some Dripper<State, Action>) {
        self.init(internal: dripper.pour)
    }

    @inlinable
    public func pour(_ state: State, _ action: Action) -> State {
        self.drip(state, action)
    }
}
