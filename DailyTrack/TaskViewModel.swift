//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.2 - Added toggleCompletion, improved comments and versioning
//  Last modified: 10/6/25
//

import Foundation
import SwiftUI

/// ViewModel para gestionar las tareas
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    /// Cargar tareas desde JSON Data
    func loadTasks(from data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedTasks = try decoder.decode([Task].self, from: data)
            DispatchQueue.main.async {
                self.tasks = decodedTasks
                print("✅ Tareas cargadas correctamente")
            }
        } catch {
            print("❌ Error al cargar tareas: \(error)")
        }
    }
    
    /// Agregar nueva tarea
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
    }
    
    /// Eliminar tarea usando IndexSet (compatible con .onDelete)
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    /// Actualizar fecha de última modificación de una tarea
    func updateTaskDate(index: Int) {
        // Convertimos Date() a timestamp String
        let timestamp = String(Int(Date().timeIntervalSince1970))
        tasks[index].updatedAt = timestamp
    }
}
