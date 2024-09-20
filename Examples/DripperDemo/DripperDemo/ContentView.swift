//
//  ContentView.swift
//  DripperDemo
//
//  Created by 이창준 on 8/13/24.
//

import SwiftUI

struct ContentView: View {

    var counter: Counter = .init()

    var body: some View {
        VStack(spacing: 12.0) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button {
                let a = counter.drip(.init(), .increaseCounter)
                print(a.counter)
            } label: {
                Text("+1")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
