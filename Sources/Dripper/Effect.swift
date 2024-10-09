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
    public typealias Blend = (_ blend: Pour<Action>) async -> Void

    @usableFromInline let blend: Blend

    @usableFromInline
    init(blend: @escaping Blend) {
        self.blend = blend
    }
}

// MARK: - Pour

@MainActor
public struct Pour<Action>: Sendable {
    let pour: @MainActor @Sendable (Action) -> Void

    @usableFromInline
    init(pour: @escaping @MainActor @Sendable (Action) -> Void) {
        self.pour = pour
    }

    public func callAsFunction(_ action: Action) {
        guard !Task.isCancelled else { return }
        pour(action)
    }
}

extension Effect {

    // MARK: Static Computed Properties

    @inlinable
    public static var none: Self {
        Self { _ in }
    }

    // MARK: Static Functions

    public static func run(
        blend: @escaping (_ pour: Pour<Action>) async throws -> Void,
        catch errorHandler: ((_ error: any Error, _ pour: Pour<Action>) async -> Void)? = nil,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> Self {
        Self { pour in
            do {
                try await blend(pour)
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
