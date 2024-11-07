//
//  Counter.swift
//  Counter
//
//  Created by 이창준 on 8/13/24.
//

import Observation
import OSLog

import Dripper

// MARK: - Counter

struct Counter: Dripper {

    // MARK: Nested Types

    @Observable
    // `State` is thread-safe when used within `Station`. We're using actor
    // `StateHandler` for thread-safe mutation.
    // swiftlint:disable:next no_unchecked_sendable
    final class State: @unchecked Sendable, CustomStringConvertible {

        // MARK: Properties

        var counter: Int = .zero
        var text = ""

        @ObservationIgnored private let id: UUID

        // MARK: Computed Properties

        var description: String {
            "Count: \(counter)"
        }

        // MARK: Lifecycle

        init(counter: Int = .zero, text: String = "") {
            let id = UUID()
            self.id = id
            self.counter = counter
            self.text = text
            os_log("State initialized: \(id)")
        }

        deinit {
            os_log("State deinitialized: \(self.id)")
        }
    }

    enum Action {
        case increaseCounter
        case decreaseCounter
        case setCounter(value: Int)
        case resetCounter
        case randomNumber
    }

    // MARK: Computed Properties

    var body: some Dripper<State, Action> {
        Drip { state, action in
            switch action {
            case .increaseCounter:
                state.counter += 1
            case .decreaseCounter:
                state.counter -= 1
            case .setCounter(let value):
                state.counter = value
            case .resetCounter:
                state.counter = .zero
            case .randomNumber:
                return .run { pour in
                    let randomNumber = try await randomNumber()
                    pour(.setCounter(value: randomNumber))
                }
            }

            return .none
        }
    }

    // MARK: Functions

    private func randomNumber() async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        return Int.random(in: 1...100)
    }
}

import SwiftUI

// MARK: - CounterView

struct CounterView: View {

    // MARK: Properties

    let station: StationOf<Counter>

    // MARK: Content

    var body: some View {
        VStack {
            Text("\(station.counter)")
                .monospacedDigit()

            HStack {
                Button("-") {
                    station.pour(.decreaseCounter)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 10.0))

                Button("+") {
                    station.pour(.increaseCounter)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 10.0))
            }

            Button("Reset") {
                station.pour(.resetCounter)
            }
            .padding()
            .foregroundStyle(.red)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 10.0))

            Button("Feeling Lucky?") {
                station.pour(.randomNumber)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 10.0))

            TextField(text: station.bind(\.text)) {
                Text("Enter you name here")
            }
            .textFieldStyle(.roundedBorder)
            .padding()

            Text(station.text)
        }
        .font(.headline)
    }
}

#Preview {
    CounterView(
        station: Station(initialState: Counter.State()) {
            Counter()
        }
    )
}
