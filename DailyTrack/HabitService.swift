//
//  HabitService.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/9/25.
//  Version 1.0 - Fase 8: Servicio de gestión de hábitos
//

import Foundation

/// Servicio dedicado a la gestión de hábitos y autorrenovación.
class HabitService: ObservableObject {
    
    // MARK: - Propiedades
    @Published var habits: [Task] = []
    private let calendar = Calendar.current
    
    // MARK: - Inicialización
    init() {
        // Podemos cargar hábitos desde UserDefaults si es necesario en el futuro
    }
    
    // MARK: - Funciones Principales
    
    /// Filtra las tareas que son hábitos
    func filterHabits(from tasks: [Task]) -> [Task] {
        return tasks.filter { $0.isHabit }
    }
    
    /// Actualiza la lista de hábitos a partir de todas las tareas
    func updateHabits(from tasks: [Task]) {
        habits = filterHabits(from: tasks)
    }
    
    /// Realiza la autorrenovación de hábitos basándose en su frecuencia
    func autoRenewHabits(tasks: inout [Task]) {
        let now = Date()
        
        for index in tasks.indices where tasks[index].isHabit {
            var task = tasks[index]
            
            if task.shouldAutoRenew() {
                print("🔄 Autorrenovando hábito: \(task.title)")
                task.resetForNewPeriod()
                tasks[index] = task
            }
        }
    }
    
    /// Comprueba y actualiza las rachas de hábitos
    func updateHabitStreaks(tasks: inout [Task]) {
        for index in tasks.indices where tasks[index].isHabit {
            var task = tasks[index]
            
            // Si el hábito está completado pero no tiene lastCompletionDate, actualizar
            if task.isCompleted && task.lastCompletionDate == nil {
                task.lastCompletionDate = task.completedAt
                tasks[index] = task
            }
        }
    }
    
    /// Calcula la consistencia general de todos los hábitos
    func overallConsistency() -> Double {
        guard !habits.isEmpty else { return 0.0 }
        
        let totalConsistency = habits.reduce(0.0) { $0 + $1.consistencyPercentage() }
        return totalConsistency / Double(habits.count)
    }
    
    /// Obtiene los hábitos por frecuencia
    func habitsByFrequency(_ frequency: HabitFrequency) -> [Task] {
        return habits.filter { $0.habitFrequency == frequency }
    }
    
    /// Obtiene los hábitos con la racha más larga
    func topHabitsByStreak(limit: Int = 5) -> [Task] {
        return habits.sorted { $0.habitStreak > $1.habitStreak }.prefix(limit).map { $0 }
    }
    
    /// Obtiene los hábitos que necesitan atención (rachas rotas o baja consistencia)
    func habitsNeedingAttention() -> [Task] {
        return habits.filter { habit in
            let consistency = habit.consistencyPercentage()
            return consistency < 0.5 || habit.habitStreak == 0
        }
    }
    
    /// Genera un reporte de progreso de hábitos
    func generateHabitReport() -> HabitReport {
        let totalHabits = habits.count
        let completedToday = habits.filter { $0.isCompleted && calendar.isDateInToday($0.completedAt ?? Date.distantPast) }.count
        let averageConsistency = overallConsistency()
        let longestStreak = habits.map { $0.habitStreak }.max() ?? 0
        
        return HabitReport(
            totalHabits: totalHabits,
            completedToday: completedToday,
            averageConsistency: averageConsistency,
            longestStreak: longestStreak,
            needsAttention: habitsNeedingAttention().count
        )
    }
}

// MARK: - Modelo de Reporte de Hábitos
struct HabitReport {
    let totalHabits: Int
    let completedToday: Int
    let averageConsistency: Double
    let longestStreak: Int
    let needsAttention: Int
    
    var completionRate: Double {
        guard totalHabits > 0 else { return 0.0 }
        return Double(completedToday) / Double(totalHabits)
    }
    
    var formattedConsistency: String {
        return String(format: "%.1f%%", averageConsistency * 100)
    }
    
    var formattedCompletionRate: String {
        return String(format: "%.1f%%", completionRate * 100)
    }
}
