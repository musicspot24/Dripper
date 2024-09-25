//
//  Effect.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation

public struct Effect<Action> {
    public typealias ActionHandler = @MainActor @Sendable (Action) -> Void

    public let run: (_ action: ActionHandler) async throws -> Void

    public init(run: @escaping (_ action: ActionHandler) async throws -> Void) {
        self.run = run
    }
}
