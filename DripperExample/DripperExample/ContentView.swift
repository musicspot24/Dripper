//
//  ContentView.swift
//  DripperExample
//
//  Created by 이창준 on 8/15/24.
//

import SwiftUI

import Dripper

struct ContentView: View {
    @Environment(\.counterDripper)
    var dripper: Dripper<CounterState, CounterAction>

    var body: some View {
        VStack {
            Text("\(dripper.currentValue.count)")

            Button {
                dripper.pour(.incCounter)
            } label: {
                Text("+")
            }

            Button {
                dripper.pour(.decCounter)
            } label: {
                Text("-")
            }
        }
        .padding()
    }
}

func counterReducer(
    state: inout CounterState,
    action: CounterAction
) {
    switch action {
    case .incCounter:
        state.count += 1
    case .decCounter:
        state.count -= 1
    }
}

extension EnvironmentValues {
    @Entry var counterDripper = Dripper<CounterState, CounterAction>(
        initialValue: .init(),
        reducer: counterReducer
    )
}

#Preview {
    ContentView()
        .environment(
            \.counterDripper,
             .init(initialValue: CounterState(), reducer: counterReducer)
        )
}
