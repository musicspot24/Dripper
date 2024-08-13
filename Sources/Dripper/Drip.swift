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

    public init(_ drip: @escaping (_ state: State, _ action: Action) -> State) {
        self.drip = drip
    }

    public func pour(_ state: State, _ action: Action) -> State {
        self.drip(state, action)
    }
}
