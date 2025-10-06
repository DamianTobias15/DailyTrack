//
//  ContentView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 9/26/25.
//  Add element check

import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = [
        Task(title: "Estudiar Swift"),
        Task(title: "Hacer ejercicio"),
        Task(title: "Leer 20 páginas"),
        Task (title: "Hacer ejecicio")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("DailyTrack ✅")
        }
    }
}

#Preview {
    ContentView()
}
