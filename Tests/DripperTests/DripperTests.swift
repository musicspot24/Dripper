//
//  DripperTests.swift
//  Dripper
//
//  Created by 이창준 on 9/27/24.
//

import Foundation
import OSLog
import Testing

@testable import Dripper

// MARK: - Heartbeat

struct Heartbeat<C: Clock>: AsyncSequence, Sendable {

    // MARK: Nested Types

    public struct HeartbeatIterator: AsyncIteratorProtocol {

        // MARK: Properties

        var clock: C
        let duration: C.Duration
        let deadline: C.Instant?
        let maxBeats: Int?
        var beatCount: Int = .zero

        // MARK: Lifecycle

        init(clock: C, duration: C.Duration, deadline: C.Duration?, maxBeats: Int?) {
            self.clock = clock
            self.duration = duration
            self.deadline = deadline.map { clock.now.advanced(by: $0) } ?? nil
            self.maxBeats = maxBeats
        }

        // MARK: Functions

        public mutating func next() async -> C.Instant? {
            defer { beatCount += 1 }
            if let maxBeats, beatCount >= maxBeats {
                return nil
            }

            if let deadline, clock.now >= deadline {
                return nil
            }

            do {
                try await clock.sleep(for: duration)
            } catch {
                return nil
            }

            return clock.now
        }
    }

    // MARK: Properties

    let clock: C
    let duration: C.Duration
    let deadline: C.Duration?
    let maxBeats: Int?

    // MARK: Lifecycle

    init(clock: C, duration: C.Duration, deadline: C.Duration? = nil, maxBeats: Int? = nil) {
        self.clock = clock
        self.duration = duration
        self.deadline = deadline
        self.maxBeats = maxBeats
    }

    // MARK: Functions

    public func makeAsyncIterator() -> HeartbeatIterator {
        HeartbeatIterator(clock: clock, duration: duration, deadline: deadline, maxBeats: maxBeats)
    }
}

// MARK: - TestDripper

struct TestDripper: Dripper {

    // MARK: Nested Types

    enum Action {
        case increase(by: Int = 1)
    }

    @MainActor
    @Observable
    final class State: Sendable {

        // MARK: Properties

        var counter: Int = .zero

        // MARK: Lifecycle

        init(counter: Int = .zero) {
            self.counter = counter
        }
    }

    // MARK: Computed Properties

    var body: some Dripper<State, Action> {
        Drip { state, action in
            switch action {
            case .increase(let amount):
                state.counter += amount
                os_log(.info, "\(state.counter)")
                return .none
            }
        }
    }
}

// MARK: - DripperTests

struct DripperTests {

    @Test
    func example() async throws {
        let station = await StateHandler(initialState: TestDripper.State(), dripper: TestDripper())

        let heartbeat = Heartbeat(clock: ContinuousClock(), duration: .seconds(2))
        Task {
            for await _ in heartbeat {
                await station.pour(.increase(by: 1))
            }
        }

        let heartbeat2 = Heartbeat(clock: ContinuousClock(), duration: .seconds(2))
        Task {
            for await _ in heartbeat2 {
                await station.pour(.increase(by: 2))
            }
        }

        try await Task.sleep(for: .seconds(20))

        #expect(await station.counter == 1)
    }

}
