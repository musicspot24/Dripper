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
    final class State {
        var counter: Int = .zero
    }

    enum Action {
        case increaseCounter
        case decreaseCounter
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
            case .resetCounter:
                state.counter = .zero
            case .randomNumber:
                return .run { pour in
                    func randomNumber() async throws -> Int {
                        try await Task.sleep(for: .seconds(1))
                        return Int.random(in: 0...10)
                    }
                    let randomNumber = try await randomNumber()
                    await pour(.decreaseCounter)
                    state.counter = randomNumber
                }
            }

            return .none
        }
    }
}

import SwiftUI

// MARK: - CounterView

struct CounterView: View {

    // MARK: Properties

    var station: StationOf<Counter>

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

#Preview {
    CounterView(
        station: Station(
            initialState: Counter.State(),
            dripper: Counter()
        )
    )
}
