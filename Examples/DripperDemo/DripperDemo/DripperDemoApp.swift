//
//  DripperDemoApp.swift
//  DripperDemo
//
//  Created by 이창준 on 8/13/24.
//

import SwiftUI

import Dripper

@main
struct DripperDemoApp: App {
    private let counterStation = Station(initialState: Counter.State()) {
        Counter()
    }

    var body: some Scene {
        WindowGroup {
            CounterView(station: counterStation)
        }
    }
}
