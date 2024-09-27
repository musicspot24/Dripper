//
//  Dripper.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

public typealias DripperOf<D: Dripper> = Dripper<D.State, D.Action>

// MARK: - Dripper

public protocol Dripper<State, Action> {
    associatedtype State: Observable
    associatedtype Action
    associatedtype Body

    func drip(_ state: State, _ action: Action) -> Effect<Action>?

    @DripperBuilder<State, Action>
    var body: Body { get }
}

extension Dripper where Body == Never {
    public var body: Body {
        fatalError()
    }
}

extension Dripper where Body: Dripper<State, Action> {
    @inlinable
    public func drip(_ state: Body.State, _ action: Body.Action) -> Effect<Action>? {
        body.drip(state, action)
    }
}
