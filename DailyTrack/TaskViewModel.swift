//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.3 - Fix delete functionality, improved persistence, detailed comments
//  Last modified: 10/6/25
//

import Foundation
import SwiftUI

/// ViewModel para gestionar las tareas del DailyTrack
class TaskViewModel: ObservableObject {
    /// Lista de tareas publicada para actualizar la UI automáticamente
    @Published var tasks: [Task] = [] {
        didSet {
            // Guardar tareas cada vez que cambian
            saveTasks()
        }
    }
    
    // MARK: - Persistencia
    
    private let tasksKey = "DailyTrackTasks" // clave para UserDefaults
    
    /// Cargar tareas desde UserDefaults
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            let decoder = JSONDecoder()
            do {
                let decodedTasks = try decoder.decode([Task].self, from: data)
                DispatchQueue.main.async {
                    self.tasks = decodedTasks
                    print("✅ Tareas cargadas correctamente")
                }
            } catch {
                print("❌ Error al decodificar tareas: \(error)")
            }
        } else {
            print("⚠️ No se encontraron tareas guardadas")
        }
    }
    
    /// Guardar tareas en UserDefaults
    func saveTasks() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)
            print("💾 Tareas guardadas correctamente")
        } catch {
            print("❌ Error al guardar tareas: \(error)")
        }
    }
    
    // MARK: - Funcionalidad de tareas
    
    /// Agregar nueva tarea
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
        print("➕ Tarea añadida: \(title)")
    }
    
    /// Eliminar tarea usando IndexSet (compatible con .onDelete)
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        print("🗑️ Tarea(s) eliminada(s)")
    }
    
    /// Marcar tarea como completada / no completada
    func toggleCompletion(index: Int) {
        tasks[index].isCompleted.toggle()
        updateTaskDate(index: index)
        print("✅ Tarea '\(tasks[index].title)' completada: \(tasks[index].isCompleted)")
    }
    
    /// Actualizar fecha de última modificación de una tarea
    func updateTaskDate(index: Int) {
        // Guardamos como timestamp en String
        let timestamp = String(Int(Date().timeIntervalSince1970))
        tasks[index].updatedAt = timestamp
    }
}
