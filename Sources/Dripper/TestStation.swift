//
//  TestStation.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation

// MARK: - TestStation

public final class TestStation<State, Action> {

    // MARK: Properties

    //    private let fileID: StaticString
    //    private let filePath: StaticString
    //    private let line: UInt
    //    private let column: UInt

    //    public var timeout: UInt64

    var state: State

    private let dripper: any Dripper<State, Action>

    // MARK: Lifecycle

    public convenience init(
        initialState: State,
        dripper: some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripper)
    }

    public convenience init(
        initialState: State,
        @DripperBuilder<State, Action> _ dripperBuilder: () -> some Dripper<State, Action>
    ) {
        self.init(state: initialState, dripper: dripperBuilder())
    }

    init<D: Dripper>(
        state: D.State,
        dripper: D
    ) where D.State == State, D.Action == Action {
        self.state = state
        self.dripper = dripper
    }

    // MARK: Functions

    public func pour(
        _: Action,
        assert _: ((_ state: State) throws -> Void)? = nil,
        fileID _: StaticString = #fileID,
        file _: StaticString = #filePath,
        line _: UInt = #line,
        column _: UInt = #column
    ) async {
        // TODO: Implement testing pour
    }
}

// MARK: - TestDripper

class TestDripper: Dripper {

    // MARK: Nested Types

    @Observable
    final class State { }

    struct Action { }

    // MARK: Computed Properties

    var body: some Dripper<State, Action> {
        Drip(internal: { _, _ in
            return {  return nil }
        })
    }
}
