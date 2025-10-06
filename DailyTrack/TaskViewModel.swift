//
//  TaskViewModel.swift
//  DailyTrack
//
//  Version 1.3 - Fase 5: Agregado método para estadísticas semanales
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleTaskCompletion(index: Int) {
        tasks[index].isCompleted.toggle()
        tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
        updateTaskDate(index: index)
    }
    
    func updateTaskDate(index: Int) {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        tasks[index].updatedAt = timestamp
    }
    
    // MARK: - Estadísticas semanales
    func weeklyStats() -> [Int] {
        // Retorna 7 valores: cantidad de tareas completadas cada día (domingo=0,...)
        var stats = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        
        for task in tasks {
            if let completed = task.completedAt {
                let weekday = calendar.component(.weekday, from: completed) - 1 // domingo=0
                stats[weekday] += 1
            }
        }
        return stats
    }
}
