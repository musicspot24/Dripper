//
//  Dripper.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

public protocol Dripper<State, Action> {
    associatedtype State
    associatedtype Action
    associatedtype Body

    func pour(_ state: State, _ action: Action) -> State

    @DripperBuilder<State, Action>
    var body: Body { get }
}

extension Dripper where Body: Dripper<State, Action> {
    @inlinable
    public func pour(_ state: State, _ action: Action) -> State {
        body.pour(state, action)
    }
}
