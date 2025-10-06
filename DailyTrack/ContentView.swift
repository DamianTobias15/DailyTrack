//
//  ContentView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.2 - Compatible con TaskViewModel actualizado, toggle y delete funcionando
//  Last modified: 10/6/25
//

import SwiftUI

struct ContentView: View {
    /// Instancia del ViewModel de tareas
    @StateObject var taskVM = TaskViewModel()
    
    /// Título de la nueva tarea a añadir
    @State private var newTaskTitle: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Input para nueva tarea
                HStack {
                    TextField("Nueva tarea", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Validación: no permitir tareas vacías
                        guard !newTaskTitle.isEmpty else { return }
                        taskVM.addTask(title: newTaskTitle)
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.trailing)
                }
                
                // MARK: - Lista de tareas
                List {
                    ForEach(taskVM.tasks.indices, id: \.self) { index in
                        HStack {
                            Text(taskVM.tasks[index].title)
                            
                            Spacer()
                            
                            // Indicador visual de completado
                            if taskVM.tasks[index].isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle()) // hace que todo el HStack sea "clickeable"
                        .onTapGesture {
                            // Toggle completado y actualización de fecha
                            taskVM.toggleCompletion(index: index)
                        }
                    }
                    // Swipe para eliminar tareas (IndexSet)
                    .onDelete(perform: taskVM.deleteTask)
                }
            }
            .navigationTitle("Mis Tareas")
            .onAppear {
                // Cargar tareas guardadas al iniciar la vista
                taskVM.loadTasks()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
