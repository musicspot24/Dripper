//
//  StateYieldPolicy.swift
//  Dripper
//
//  Created by 이창준 on 10/11/24.
//

// MARK: - StateYieldPolicy

protocol StateYieldPolicy {
    associatedtype State
    func shouldYield(oldValue: State, newValue: State) -> Bool
}

extension StateYieldPolicy {
    func shouldYield(oldValue _: State, newValue _: State) -> Bool {
        true
    }
}

extension StateYieldPolicy where State: Equatable {
    func shouldYield(oldValue: State, newValue: State) -> Bool {
        oldValue != newValue
    }
}
