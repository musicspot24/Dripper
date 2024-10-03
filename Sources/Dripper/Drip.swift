//
//  Drip.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

public struct Drip<State: Observable & Sendable, Action>: Dripper {

    // MARK: Properties

    @usableFromInline let drip: (State, Action) -> Effect<Action>?

    // MARK: Lifecycle

    @inlinable
    public init(_ drip: @escaping (_ state: State, _ action: Action) -> Effect<Action>) {
        self.init(internal: drip)
    }

    public init(_ dripper: some Dripper<State, Action>) {
        self.init(internal: dripper.drip)
    }

    @usableFromInline
    init(internal drip: @escaping (_ state: State, _ action: Action) -> Effect<Action>?) {
        self.drip = drip
    }

    // MARK: Functions

    @inlinable
    public func drip(_ state: State, _ action: Action) -> Effect<Action>? {
        drip(state, action)
    }
}
