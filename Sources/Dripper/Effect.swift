//
//  Effect.swift
//  Dripper
//
//  Created by 이창준 on 9/20/24.
//

import Foundation
import OSLog

// MARK: - Effect

public struct Effect<Action> {
    public typealias Kettle = @Sendable (_ blend: Pour<Action>) async -> Void

    @usableFromInline let kettle: Kettle

    @usableFromInline
    init(kettle: @escaping Kettle) {
        self.kettle = kettle
    }
}

// MARK: - Pour

@MainActor
public struct Pour<Action>: Sendable {
    let pour: @MainActor @Sendable (Action) -> Void

    init(pour: @escaping @MainActor @Sendable (Action) -> Void) {
        self.pour = pour
    }

    public func callAsFunction(_ action: Action) {
        pour(action)
    }
}

extension Effect {

    // MARK: Static Computed Properties

    public static var none: Self {
        Self { _ in }
    }

    // MARK: Static Functions

    public static func run(
        kettle: @escaping @Sendable (_ pour: Pour<Action>) async throws -> Void,
        catch errorHandler: (@Sendable (_ error: any Error, _ pour: Pour<Action>) async -> Void)? = nil,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> Self {
        Self { pour in
            do {
                try await kettle(pour)
            } catch {
                guard let errorHandler else {
                    os_log(
                        .fault,
                        """
                        An "Effect.run" returned from "\(fileID):\(line)" threw an unhandled error.
                        This error must be handled via the `catch` parameter.
                        """
                    )
                    return
                }
                await errorHandler(error, pour)
            }
        }
    }
}
