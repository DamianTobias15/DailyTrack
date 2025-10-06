//
//  ContentView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.1 - Refactored for performance and preview stability
//  Last modified: 10/6/25
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject var taskVM = TaskViewModel()
    @State private var newTaskTitle: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Nueva tarea", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        taskVM.addTask(title: newTaskTitle)
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.trailing)
                }
                
                List {
                    ForEach(taskVM.tasks.indices, id: \.self) { index in
                        HStack {
                            Text(taskVM.tasks[index].title)
                            Spacer()
                            if taskVM.tasks[index].isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            taskVM.tasks[index].isCompleted.toggle()
                            taskVM.updateTaskDate(index: index)
                        }
                    }
                    .onDelete(perform: taskVM.deleteTask) // ✅ Corregido: recibe IndexSet
                }
            }
            .navigationTitle("Mis Tareas")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
