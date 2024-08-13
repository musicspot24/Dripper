//
//  DripperBuilder.swift
//  Dripper
//
//  Created by 이창준 on 8/13/24.
//

@resultBuilder
public enum DripperBuilder<State, Action> {
    @inlinable
    public static func buildBlock<D: Dripper<State, Action>>(_ dripper: D) -> D {
        dripper
    }
}
