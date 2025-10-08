//
//  Task.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 2.0 - Fase 8: Sistema de Hábitos + Mejoras Existentes
//  Last modified: 10/9/25
//

import Foundation

// MARK: - Enums para Hábitos
enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Diario"
    case weekly = "Semanal"
    case monthly = "Mensual"
}

/// Modelo principal de Tarea.
/// Soporta decodificación segura, versionado y compatibilidad futura.
struct Task: Codable, Identifiable {
    
    // MARK: - Propiedades principales
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date                     // Fecha de creación
    var completedAt: Date?                  // Fecha de completado (nil si pendiente)
    var updatedAt: String                   // Timestamp (string) de última modificación
    var version: Int                        // Versión del modelo
    
    // MARK: - Fase 6: Categorías, Colaboradores y Recordatorios
    var categoryId: UUID?                   // ID de la categoría asociada
    var assignedTo: UUID?                   // ID del colaborador asignado
    var reminderDate: Date?                 // Fecha y hora de recordatorio opcional
    
    // MARK: - Fase 8: Sistema de Hábitos 🌱
    var isHabit: Bool                       // Indica si es un hábito
    var habitStreak: Int                    // Conteo actual de racha
    var habitFrequency: HabitFrequency      // Frecuencia del hábito
    var lastCompletionDate: Date?           // Última fecha de completado
    var habitStartDate: Date?               // Fecha de inicio del hábito
    
    // MARK: - Claves de codificación
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, completedAt, updatedAt, version
        case categoryId, assignedTo, reminderDate
        case isHabit, habitStreak, habitFrequency, lastCompletionDate, habitStartDate
    }
    
    // MARK: - Decodificación segura (JSON)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        version = (try? container.decode(Int.self, forKey: .version)) ?? 1
        categoryId = try? container.decode(UUID.self, forKey: .categoryId)
        assignedTo = try? container.decode(UUID.self, forKey: .assignedTo)
        reminderDate = try? container.decode(Date.self, forKey: .reminderDate)
        
        // Fase 8: Propiedades de hábitos con valores por defecto
        isHabit = (try? container.decode(Bool.self, forKey: .isHabit)) ?? false
        habitStreak = (try? container.decode(Int.self, forKey: .habitStreak)) ?? 0
        habitFrequency = (try? container.decode(HabitFrequency.self, forKey: .habitFrequency)) ?? .daily
        lastCompletionDate = try? container.decode(Date.self, forKey: .lastCompletionDate)
        habitStartDate = try? container.decode(Date.self, forKey: .habitStartDate)
        
        // createdAt: soporta Date, Double o Int
        if let ts = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: ts)
        } else if let ts = try? container.decode(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: Double(ts))
        } else {
            createdAt = (try? container.decode(Date.self, forKey: .createdAt)) ?? Date()
        }
        
        // completedAt: soporta nil, Date o timestamp
        if let ts = try? container.decode(Double.self, forKey: .completedAt) {
            completedAt = Date(timeIntervalSince1970: ts)
        } else if let ts = try? container.decode(Int.self, forKey: .completedAt) {
            completedAt = Date(timeIntervalSince1970: Double(ts))
        } else {
            completedAt = try? container.decode(Date.self, forKey: .completedAt)
        }
        
        // updatedAt: soporta String, Double o Int
        if let str = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = str
        } else if let ts = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = String(Int(ts))
        } else if let ts = try? container.decode(Int.self, forKey: .updatedAt) {
            updatedAt = String(ts)
        } else {
            updatedAt = "\(Int(Date().timeIntervalSince1970))"
        }
    }
    
    // MARK: - Inicializador directo (desde código)
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        updatedAt: String = "\(Int(Date().timeIntervalSince1970))",
        version: Int = 1,
        categoryId: UUID? = nil,
        assignedTo: UUID? = nil,
        reminderDate: Date? = nil,
        // Fase 8: Nuevos parámetros para hábitos
        isHabit: Bool = false,
        habitStreak: Int = 0,
        habitFrequency: HabitFrequency = .daily,
        lastCompletionDate: Date? = nil,
        habitStartDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.updatedAt = updatedAt
        self.version = version
        self.categoryId = categoryId
        self.assignedTo = assignedTo
        self.reminderDate = reminderDate
        // Fase 8: Inicialización de hábitos
        self.isHabit = isHabit
        self.habitStreak = habitStreak
        self.habitFrequency = habitFrequency
        self.lastCompletionDate = lastCompletionDate
        self.habitStartDate = habitStartDate ?? (isHabit ? createdAt : nil)
    }
    
    // MARK: - Funciones auxiliares EXISTENTES
    /// Indica si la tarea fue completada dentro de la semana actual.
    func completedThisWeek() -> Bool {
        guard let completedAt else { return false }
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return false }
        return completedAt >= startOfWeek
    }
    
    /// Devuelve true si tiene categoría asignada
    func hasCategory() -> Bool {
        return categoryId != nil
    }
    
    /// Devuelve true si tiene colaborador asignado
    func hasCollaborator() -> Bool {
        return assignedTo != nil
    }
}

// MARK: - Fase 8: Extensión para Lógica de Hábitos 🌱
extension Task {
    
    /// Verifica si el hábito ha completado una racha específica
    func hasCompletedStreak(of days: Int) -> Bool {
        guard isHabit else { return false }
        return habitStreak >= days
    }
    
    /// Reinicia el hábito para un nuevo período (semanal/mensual)
    mutating func resetForNewPeriod() {
        guard isHabit else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch habitFrequency {
        case .daily:
            // Para hábitos diarios, verificamos si pasó más de un día
            if let lastCompletion = lastCompletionDate {
                let daysSinceCompletion = calendar.dateComponents([.day], from: lastCompletion, to: now).day ?? 0
                if daysSinceCompletion > 1 {
                    // Rompió la racha
                    habitStreak = 0
                }
            }
            
        case .weekly:
            // Para hábitos semanales, reiniciamos cada semana
            if let lastCompletion = lastCompletionDate {
                let weekOfYear = calendar.component(.weekOfYear, from: lastCompletion)
                let currentWeek = calendar.component(.weekOfYear, from: now)
                
                if currentWeek != weekOfYear {
                    // Nueva semana, mantenemos la racha pero reiniciamos el estado de completado
                    isCompleted = false
                }
            }
            
        case .monthly:
            // Para hábitos mensuales, reiniciamos cada mes
            if let lastCompletion = lastCompletionDate {
                let month = calendar.component(.month, from: lastCompletion)
                let currentMonth = calendar.component(.month, from: now)
                
                if currentMonth != month {
                    isCompleted = false
                }
            }
        }
    }
    
    /// Determina si el hábito debe renovarse automáticamente
    func shouldAutoRenew() -> Bool {
        guard isHabit, !isCompleted else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch habitFrequency {
        case .daily:
            // Renovar diariamente si no se completó hoy
            if let lastCompletion = lastCompletionDate {
                return !calendar.isDateInToday(lastCompletion)
            }
            return true
            
        case .weekly:
            // Renovar semanalmente si estamos en una nueva semana
            if let lastCompletion = lastCompletionDate {
                let weekOfYear = calendar.component(.weekOfYear, from: lastCompletion)
                let currentWeek = calendar.component(.weekOfYear, from: now)
                return currentWeek != weekOfYear
            }
            return true
            
        case .monthly:
            // Renovar mensualmente si estamos en un nuevo mes
            if let lastCompletion = lastCompletionDate {
                let month = calendar.component(.month, from: lastCompletion)
                let currentMonth = calendar.component(.month, from: now)
                return currentMonth != month
            }
            return true
        }
    }
    
    /// Calcula la consistencia del hábito como porcentaje
    func consistencyPercentage() -> Double {
        guard isHabit, let startDate = habitStartDate else { return 0.0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        let totalPeriods: Int
        switch habitFrequency {
        case .daily:
            totalPeriods = max(1, calendar.dateComponents([.day], from: startDate, to: now).day ?? 1)
        case .weekly:
            totalPeriods = max(1, calendar.dateComponents([.weekOfYear], from: startDate, to: now).weekOfYear ?? 1)
        case .monthly:
            totalPeriods = max(1, calendar.dateComponents([.month], from: startDate, to: now).month ?? 1)
        }
        
        return Double(habitStreak) / Double(totalPeriods)
    }
    
    /// Incrementa la racha cuando se completa el hábito
    mutating func incrementStreak() {
        guard isHabit else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        if let lastCompletion = lastCompletionDate {
            // Verificar si se completó consecutivamente
            switch habitFrequency {
            case .daily:
                let daysBetween = calendar.dateComponents([.day], from: lastCompletion, to: now).day ?? 0
                if daysBetween == 1 {
                    habitStreak += 1
                } else if daysBetween > 1 {
                    // Rompió la racha, reiniciar
                    habitStreak = 1
                }
                
            case .weekly:
                let weeksBetween = calendar.dateComponents([.weekOfYear], from: lastCompletion, to: now).weekOfYear ?? 0
                if weeksBetween == 1 {
                    habitStreak += 1
                } else if weeksBetween > 1 {
                    habitStreak = 1
                }
                
            case .monthly:
                let monthsBetween = calendar.dateComponents([.month], from: lastCompletion, to: now).month ?? 0
                if monthsBetween == 1 {
                    habitStreak += 1
                } else if monthsBetween > 1 {
                    habitStreak = 1
                }
            }
        } else {
            // Primera vez que se completa
            habitStreak = 1
        }
        
        lastCompletionDate = now
        completedAt = now
        isCompleted = true
        updatedAt = "\(Int(Date().timeIntervalSince1970))"
    }
}

// MARK: - Utilidades para Hábitos
extension Task {
    /// Descripción amigable de la frecuencia
    var frequencyDescription: String {
        habitFrequency.rawValue
    }
    
    /// Emoji representativo según la frecuencia
    var frequencyEmoji: String {
        switch habitFrequency {
        case .daily: return "📅"
        case .weekly: return "📆"
        case .monthly: return "🗓️"
        }
    }
    
    /// Texto descriptivo de la racha actual
    var streakDescription: String {
        guard isHabit else { return "" }
        
        switch habitStreak {
        case 0: return "Comienza tu racha"
        case 1: return "1 día seguido"
        case 7: return "¡1 semana consecutiva! 🎉"
        case 30: return "¡1 mes consecutivo! 🌟"
        case 100: return "¡100 días! 🏆"
        default: return "\(habitStreak) días seguidos"
        }
    }
    
    /// Indica si es un hábito activo (empezado pero no necesariamente completado hoy)
    var isActiveHabit: Bool {
        isHabit && habitStartDate != nil
    }
}
