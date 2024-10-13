//
//  CounterApp.swift
//  Counter
//
//  Created by 이창준 on 8/13/24.
//

import SwiftUI

import Dripper

@main
struct CounterApp: App {

    // MARK: Properties

    @State private var path: [Int] = []

    // MARK: Computed Properties

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                List {
                    NavigationLink("1", value: 1)
                    NavigationLink("2", value: 2)
                    NavigationLink("3", value: 3)
                }
                .navigationTitle("Starting Counter")
                .navigationDestination(for: Int.self) { number in
                    CounterView(
                        station: Station(initialState: Counter.State(counter: number)) {
                            Counter()
                        }
                    )
                }
            }
        }
    }
}
