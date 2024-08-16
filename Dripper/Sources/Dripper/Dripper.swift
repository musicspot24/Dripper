//
//  Dripper.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

#if canImport(Observation) && swift(>=5.9)
import Observation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
public final class Dripper<Value, Action> {
    private let reducer: (inout Value, Action) -> Void
    private var value: Value

    public var currentValue: Value { value }

    public init(
        initialValue: Value,
        reducer: @escaping (inout Value, Action) -> Void
    ) {
        self.value = initialValue
        self.reducer = reducer
    }

    public func pour(_ action: Action) {
        reducer(&value, action)
    }
}
#else
public final class Dripper<Value, Action>: ObservableObject {
    private let reducer: (inout Value, Action) -> Void
    @Published private var value: Value

    public var currentValue: Value { value }

    public init(
        initialValue: Value,
        reducer: @escaping (inout Value, Action) -> Void
    ) {
        self.value = initialValue
        self.reducer = reducer
    }

    public func pour(_ action: Action) {
        reducer(&value, action)
    }
}
#endif

public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        reducers.forEach { $0(&value, action) }
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}
