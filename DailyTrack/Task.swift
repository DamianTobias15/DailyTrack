//
//  Task.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.6 - Fase 6: Soporte para categorías, colaboradores y recordatorios
//  Last modified: 10/7/25
//

import Foundation

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
    
    // MARK: - Claves de codificación
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, completedAt, updatedAt, version
        case categoryId, assignedTo, reminderDate
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
        reminderDate: Date? = nil
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
    }
    
    // MARK: - Funciones auxiliares
    /// Indica si la tarea fue completada dentro de la semana actual.
    func completedThisWeek() -> Bool {
        guard let completedAt else { return false }
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return false }
        return completedAt >= startOfWeek
    }
}
