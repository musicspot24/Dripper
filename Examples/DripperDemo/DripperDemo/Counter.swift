//
//  Counter.swift
//  DripperDemo
//
//  Created by 이창준 on 8/13/24.
//

import Observation

import Dripper

struct Counter: Dripper {
    @Observable
    final class State {
        var counter: Int = .zero
    }

    enum Action {
        case increaseCounter
        case decreaseCounter
        case resetCounter
    }

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

struct CounterView: View {
    var station: StationOf<Counter>

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
