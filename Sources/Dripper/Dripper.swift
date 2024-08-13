//
//  Dripper.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

public protocol Dripper<State, Action> {
    associatedtype State
    associatedtype Action

    func pour(_ state: State, _ action: Action) -> State
}
