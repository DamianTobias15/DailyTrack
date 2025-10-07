//
//  Collaborator.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 1.0 - Fase 6: Modelo de Colaboradores
//  Last modified: 10/6/25
//

import Foundation

/// Modelo de Colaborador
/// Compatible con Codable y Identifiable
struct Collaborator: Codable, Identifiable {
    
    // MARK: - Propiedades principales
    let id: UUID
    var name: String                     // Nombre del colaborador
    var contactInfo: String?             // Email o teléfono
    var version: Int                     // Versión del modelo
    var createdAt: Date = Date()         // Fecha de creación
    var updatedAt: String = String(Int(Date().timeIntervalSince1970)) // Timestamp última modificación
    
    // MARK: - Inicializador desde JSON (decodificación segura)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        version = try container.decode(Int.self, forKey: .version)
        contactInfo = try? container.decode(String.self, forKey: .contactInfo)
        
        // createdAt: soporta Date o timestamp Double/Int
        if let createdTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: createdTimestamp)
        } else if let createdTimestamp = try? container.decode(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: Double(createdTimestamp))
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
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
    
    // MARK: - Inicializador manual
    init(id: UUID = UUID(),
         name: String,
         contactInfo: String? = nil,
         version: Int = 1,
         createdAt: Date = Date(),
         updatedAt: String = "\(Int(Date().timeIntervalSince1970))") {
        
        self.id = id
        self.name = name
        self.contactInfo = contactInfo
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
