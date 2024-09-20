//
//  Counter.swift
//  DripperDemo
//
//  Created by 이창준 on 8/13/24.
//

import Observation

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
            }

            return state
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
