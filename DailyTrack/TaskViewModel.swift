//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 2.2 - Fase 6: Sincronización de vistas, modelo y corrección de estadísticas semanales (ajuste de índice de días + comentarios clarificados)
//  Last modified: 10/7/25
//

import Foundation
import SwiftUI

final class TaskViewModel: ObservableObject {
    
    // MARK: - Propiedades observadas
    @Published var tasks: [Task] = []
    
    // MARK: - Persistencia
    private let tasksKey = "tasks"
    
    // MARK: - Carga de tareas
    func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else { return }
        let decoder = JSONDecoder()
        do {
            var decodedTasks = try decoder.decode([Task].self, from: data)
            // Actualizar versión de tareas antiguas
            for i in decodedTasks.indices {
                if decodedTasks[i].version == 0 {
                    decodedTasks[i].version = 1
                }
            }
            DispatchQueue.main.async {
                self.tasks = decodedTasks
                print("✅ \(decodedTasks.count) tareas cargadas correctamente")
            }
        } catch {
            print("❌ Error al cargar tareas: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Guardado de tareas
    private func saveTasks() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)
        } catch {
            print("❌ Error al guardar tareas: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD
    
    /// Crea una nueva tarea directamente desde parámetros simples
    func addTask(title: String, categoryId: UUID? = nil, assignedTo: UUID? = nil, reminderDate: Date? = nil) {
        let newTask = Task(title: title, categoryId: categoryId, assignedTo: assignedTo, reminderDate: reminderDate)
        tasks.append(newTask)
        saveTasks()
    }
    
    /// Crea una tarea a partir de un objeto Task (usado por AddTaskView)
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    func toggleCompletion(index: Int) {
        guard tasks.indices.contains(index) else { return }
        tasks[index].isCompleted.toggle()
        tasks[index].updatedAt = String(Int(Date().timeIntervalSince1970))
        tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
        saveTasks()
    }
    
    private func updateTaskDate(index: Int) {
        guard tasks.indices.contains(index) else { return }
        tasks[index].updatedAt = String(Int(Date().timeIntervalSince1970))
    }
    
    func assignTaskToCategory(taskId: UUID, categoryId: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].categoryId = categoryId
        updateTaskDate(index: index)
        saveTasks()
    }
    
    func assignTask(taskId: UUID, collaboratorId: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].assignedTo = collaboratorId
        updateTaskDate(index: index)
        saveTasks()
    }
    
    func updateReminder(taskId: UUID, reminderDate: Date?) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].reminderDate = reminderDate
        updateTaskDate(index: index)
        saveTasks()
    }
    
    func tasks(forCategory categoryId: UUID) -> [Task] {
        tasks.filter { $0.categoryId == categoryId }
    }
    
    func tasks(forCollaborator collaboratorId: UUID) -> [Task] {
        tasks.filter { $0.assignedTo == collaboratorId }
    }
    
    // MARK: - Estadísticas semanales
    /// Retorna un array de 7 posiciones con la cantidad de tareas completadas por día
    /// Ajusta el índice para que coincida con weekDays ["Lun", "Mar", ..., "Dom"]
    func weeklyStats() -> [Int] {
        var stats = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        let now = Date()
        
        for task in tasks where task.isCompleted {
            if let completedDate = task.completedAt,
               calendar.isDate(completedDate, equalTo: now, toGranularity: .weekOfYear) {
                // Ajuste de índice: weekday domingo = 1, lunes = 2 ... -> lunes = 0
                let weekdayIndex = (calendar.component(.weekday, from: completedDate) + 5) % 7
                stats[weekdayIndex] += 1
            }
        }
        return stats
    }
}
