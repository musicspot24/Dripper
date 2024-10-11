//
//  Drip.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

public struct Drip<State: Sendable, Action>: Dripper {

    // MARK: Nested Types

    public typealias Dripping = @MainActor (_ state: State, _ action: Action) -> Effect<Action>?

    // MARK: Properties

    @usableFromInline let drip: Dripping

    // MARK: Lifecycle

    @inlinable
    public init(_ drip: @escaping Dripping) {
        self.init(internal: drip)
    }

    public init(_ dripper: some Dripper<State, Action>) {
        self.init(internal: dripper.drip)
    }

    @usableFromInline
    init(internal drip: @escaping Dripping) {
        self.drip = drip
    }

    // MARK: Functions

    @inlinable
    public func drip(_ state: State, _ action: Action) -> Effect<Action>? {
        drip(state, action)
    }
}
