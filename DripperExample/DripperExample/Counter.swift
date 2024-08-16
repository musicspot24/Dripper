//
//  Counter.swift
//  DripperExample
//
//  Created by 이창준 on 8/15/24.
//

import Dripper

struct CounterState {
    var count: Int = .zero
}

struct UserState {
    var userName: String = ""
}

enum CounterAction {
    case incCounter
    case decCounter
}
