//
//  StreakViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez.
//  Version: 1.0 - Sistema completo de rachas y logros
//  Last modified: 08/10/2025
//

import Foundation
import SwiftUI

/// ViewModel para gestionar rachas, logros y progreso continuo
/// Calcula rachas diarias, semanales y mensuales basado en tareas completadas
class StreakViewModel: ObservableObject {
    
    // MARK: - Propiedades Publicadas
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var weeklyCompletion: Double = 0.0
    @Published var monthlyCompletion: Double = 0.0
    @Published var achievements: [Achievement] = []
    @Published var streakHistory: [Date] = []
    
    // MARK: - Propiedades Privadas
    private let taskVM: TaskViewModel
    private let calendar = Calendar.current
    
    // MARK: - Inicialización
    init(taskVM: TaskViewModel) {
        self.taskVM = taskVM
        loadStreakData()
        calculateCurrentStreak()
        checkAchievements()
    }
    
    // MARK: - Cálculo de Rachas
    
    /// Calcula la racha actual basada en días consecutivos con tareas completadas
    func calculateCurrentStreak() {
        let completedDates = getCompletedDates()
        streakHistory = completedDates.sorted(by: >)
        
        guard !completedDates.isEmpty else {
            currentStreak = 0
            saveStreakData()
            return
        }
        
        var streak = 0
        var currentDate = Date()
        
        // Verificar días consecutivos hacia atrás
        while true {
            if completedDates.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
                streak += 1
                
                // Mover al día anterior
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        currentStreak = streak
        updateLongestStreak()
        saveStreakData()
    }
    
    /// Actualiza la racha más larga si la actual es mayor
    private func updateLongestStreak() {
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    /// Obtiene todas las fechas en las que se completaron tareas
    private func getCompletedDates() -> [Date] {
        var dates: [Date] = []
        
        for task in taskVM.tasks where task.isCompleted {
            if let completedDate = task.completedAt {
                dates.append(completedDate)
            }
        }
        
        // Eliminar duplicados del mismo día
        let uniqueDates = Array(Set(dates.map { calendar.startOfDay(for: $0) }))
        return uniqueDates
    }
    
    // MARK: - Cálculo de Progreso Semanal y Mensual
    
    /// Calcula el porcentaje de completado de la semana actual
    func calculateWeeklyCompletion() {
        let completedThisWeek = tasksCompletedThisWeek()
        let totalDays = 7 // Semana completa
        weeklyCompletion = Double(completedThisWeek) / Double(totalDays)
    }
    
    /// Calcula el porcentaje de completado del mes actual
    func calculateMonthlyCompletion() {
        let completedThisMonth = tasksCompletedThisMonth()
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
        monthlyCompletion = Double(completedThisMonth) / Double(daysInMonth)
    }
    
    /// Cuenta días con tareas completadas en la semana actual
    private func tasksCompletedThisWeek() -> Int {
        let completedDates = getCompletedDates()
        let now = Date()
        
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }
        
        let weekDays = completedDates.filter { date in
            date >= weekStart && date <= now
        }
        
        return Set(weekDays.map { calendar.startOfDay(for: $0) }).count
    }
    
    /// Cuenta días con tareas completadas en el mes actual
    private func tasksCompletedThisMonth() -> Int {
        let completedDates = getCompletedDates()
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        
        let monthDays = completedDates.filter { date in
            date >= monthStart && date <= now
        }
        
        return Set(monthDays.map { calendar.startOfDay(for: $0) }).count
    }
    
    // MARK: - Sistema de Logros
    
    /// Verifica y desbloquea logros basados en el progreso
    func checkAchievements() {
        var newAchievements: [Achievement] = []
        
        // Logro: Primera racha
        if currentStreak >= 1 && !achievements.contains(where: { $0.id == "first_streak" }) {
            newAchievements.append(Achievement(
                id: "first_streak",
                title: "¡Primer Paso!",
                description: "Completa tareas 1 día consecutivo",
                icon: "🎯",
                unlockedAt: Date()
            ))
        }
        
        // Logro: Racha de 3 días
        if currentStreak >= 3 && !achievements.contains(where: { $0.id == "three_day_streak" }) {
            newAchievements.append(Achievement(
                id: "three_day_streak",
                title: "En Marcha",
                description: "3 días consecutivos de productividad",
                icon: "🔥",
                unlockedAt: Date()
            ))
        }
        
        // Logro: Racha de 7 días
        if currentStreak >= 7 && !achievements.contains(where: { $0.id == "week_streak" }) {
            newAchievements.append(Achievement(
                id: "week_streak",
                title: "¡Racha Semanal!",
                description: "7 días consecutivos completando tareas",
                icon: "⭐",
                unlockedAt: Date()
            ))
        }
        
        // Logro: Racha de 30 días
        if currentStreak >= 30 && !achievements.contains(where: { $0.id == "month_streak" }) {
            newAchievements.append(Achievement(
                id: "month_streak",
                title: "¡Leyenda!",
                description: "30 días consecutivos de consistencia",
                icon: "🏆",
                unlockedAt: Date()
            ))
        }
        
        // Logro: Semana perfecta
        if weeklyCompletion >= 1.0 && !achievements.contains(where: { $0.id == "perfect_week" }) {
            newAchievements.append(Achievement(
                id: "perfect_week",
                title: "Semana Perfecta",
                description: "Completa tareas todos los días de la semana",
                icon: "💫",
                unlockedAt: Date()
            ))
        }
        
        if !newAchievements.isEmpty {
            achievements.append(contentsOf: newAchievements)
            saveStreakData()
        }
    }
    
    // MARK: - Persistencia
    
    private struct StreakData: Codable {
        let longestStreak: Int
        let achievements: [Achievement]
        let streakHistory: [Date]
    }
    
    /// Carga los datos de rachas desde UserDefaults
    private func loadStreakData() {
        if let data = UserDefaults.standard.data(forKey: "streakData") {
            let decoder = JSONDecoder()
            do {
                let streakData = try decoder.decode(StreakData.self, from: data)
                longestStreak = streakData.longestStreak
                achievements = streakData.achievements
                streakHistory = streakData.streakHistory
            } catch {
                print("❌ Error al cargar datos de rachas: \(error)")
            }
        }
    }
    
    /// Guarda los datos de rachas en UserDefaults
    private func saveStreakData() {
        let streakData = StreakData(
            longestStreak: longestStreak,
            achievements: achievements,
            streakHistory: streakHistory
        )
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(streakData)
            UserDefaults.standard.set(data, forKey: "streakData")
        } catch {
            print("❌ Error al guardar datos de rachas: \(error)")
        }
    }
    
    // MARK: - Utilidades
    
    /// Reinicia todos los datos de rachas (para testing/debug)
    func resetStreakData() {
        currentStreak = 0
        longestStreak = 0
        weeklyCompletion = 0.0
        monthlyCompletion = 0.0
        achievements = []
        streakHistory = []
        UserDefaults.standard.removeObject(forKey: "streakData")
    }
    
    /// Actualiza todos los cálculos (llamar cuando se complete una tarea)
    func refreshAllCalculations() {
        calculateCurrentStreak()
        calculateWeeklyCompletion()
        calculateMonthlyCompletion()
        checkAchievements()
    }
}

// MARK: - Modelo de Logro

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let unlockedAt: Date
}

// MARK: - Extensiones de Utilidad

extension Achievement: Equatable {
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Data

#if DEBUG
extension StreakViewModel {
    static var preview: StreakViewModel {
        let taskVM = TaskViewModel()
        let streakVM = StreakViewModel(taskVM: taskVM)
        
        // Datos de ejemplo para preview
        streakVM.currentStreak = 5
        streakVM.longestStreak = 12
        streakVM.weeklyCompletion = 0.85
        streakVM.monthlyCompletion = 0.65
        
        streakVM.achievements = [
            Achievement(
                id: "first_streak",
                title: "¡Primer Paso!",
                description: "Completa tareas 1 día consecutivo",
                icon: "🎯",
                unlockedAt: Date().addingTimeInterval(-86400 * 6) // Hace 6 días
            ),
            Achievement(
                id: "three_day_streak",
                title: "En Marcha",
                description: "3 días consecutivos de productividad",
                icon: "🔥",
                unlockedAt: Date().addingTimeInterval(-86400 * 4) // Hace 4 días
            )
        ]
        
        return streakVM
    }
}
#endif
