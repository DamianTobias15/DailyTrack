//
//  Task.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.4 - Safe Codable, full date support, versioning
//  Last modified: 10/6/25
//

import Foundation

/// Modelo de Tarea
/// Compatible con Codable, Identifiable y versiones futuras
struct Task: Codable, Identifiable {
    
    // MARK: - Propiedades principales
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date = Date()       // Fecha de creación
    var completedAt: Date? = nil       // Fecha de completado (nil si pendiente)
    var updatedAt: String = String(Int(Date().timeIntervalSince1970)) // Timestamp última modificación
    var version: Int                    // Versión del modelo
    
    // MARK: - Keys para codificación personalizada
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, completedAt, updatedAt, version
    }
    
    // MARK: - Inicializador desde JSON (decodificación segura)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        version = try container.decode(Int.self, forKey: .version)
        
        // createdAt: soporta Date o timestamp Double/Int
        if let createdTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: createdTimestamp)
        } else if let createdTimestamp = try? container.decode(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: Double(createdTimestamp))
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        // completedAt: opcional, soporta nil
        if let completedTimestamp = try? container.decode(Double.self, forKey: .completedAt) {
            completedAt = Date(timeIntervalSince1970: completedTimestamp)
        } else if let completedTimestamp = try? container.decode(Int.self, forKey: .completedAt) {
            completedAt = Date(timeIntervalSince1970: Double(completedTimestamp))
        } else {
            completedAt = try? container.decode(Date.self, forKey: .completedAt)
        }
        
        // updatedAt: soporta String o Double
        if let updatedTimestamp = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = String(Int(updatedTimestamp))
        } else if let updatedTimestamp = try? container.decode(Int.self, forKey: .updatedAt) {
            updatedAt = String(updatedTimestamp)
        } else {
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
        }
    }
    
    // MARK: - Inicializador manual desde Swift
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date(), completedAt: Date? = nil, updatedAt: String = "\(Int(Date().timeIntervalSince1970))", version: Int = 1) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.updatedAt = updatedAt
        self.version = version
    }
    
    // MARK: - Funciones de ayuda
    /// Retorna true si la tarea fue completada en la semana actual
    func completedThisWeek() -> Bool {
        guard let completedAt = completedAt else { return false }
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return completedAt >= startOfWeek
    }
}
