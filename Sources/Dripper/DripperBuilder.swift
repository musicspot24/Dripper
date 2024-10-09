//
//  DripperBuilder.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

import Foundation

@resultBuilder
public enum DripperBuilder<State: ObservableState, Action> {
    @inlinable
    public static func buildBlock<D: Dripper<State, Action>>(_ dripper: D) -> D {
        dripper
    }

    @inlinable
    public static func buildExpression<D: Dripper<State, Action>>(_ expression: D) -> D {
        expression
    }

    @inlinable
    @MainActor
    public static func buildExpression(
        _ expression: any Dripper<State, Action>
    ) -> Drip<State, Action> {
        Drip(expression)
    }

    @inlinable
    public static func buildFinalResult<D: Dripper<State, Action>>(_ dripper: D) -> D {
        dripper
    }

    @inlinable
    public static func buildOptional<D: Dripper<State, Action>>(_ wrapped: D?) -> D? {
        wrapped
    }
}
