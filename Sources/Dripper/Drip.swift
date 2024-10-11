//
//  Drip.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

public struct Drip<State: StationState, Action>: Dripper {

    // MARK: Properties

    @usableFromInline let drip: @MainActor (State, Action) -> Effect<Action>?

    // MARK: Lifecycle

    @inlinable
    public init(
        _ drip: @MainActor @escaping (_ state: State, _ action: Action) -> Effect<Action>
    ) {
        self.init(internal: drip)
    }

    @inlinable
    public init(_ dripper: some Dripper<State, Action>) {
        self.init(internal: dripper.drip)
    }

    @usableFromInline
    init(internal drip: @MainActor @escaping (State, Action) -> Effect<Action>?) {
        self.drip = drip
    }

    // MARK: Functions

    @inlinable
    public func drip(_ state: State, _ action: Action) -> Effect<Action>? {
        drip(state, action)
    }
}
