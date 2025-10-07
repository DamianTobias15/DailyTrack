//
//  Category.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 2.0 - Fase 6: Modelo de Categorías con soporte mejorado para UI
//  Last modified: \(Date())
//

import Foundation
import SwiftUI

/// Modelo de Categoría mejorado con soporte para UI
/// Compatible con Codable, Identifiable y Hashable
struct Category: Codable, Identifiable, Hashable {
    
    // MARK: - Propiedades principales
    let id: UUID
    var name: String                     // Nombre de la categoría (Ej: Trabajo, Personal)
    var colorHex: String?                // Color representativo en hex
    var iconName: String?               // Nombre del SF Symbol (nuevo)
    var version: Int                     // Versión del modelo
    var createdAt: Date = Date()         // Fecha de creación
    var updatedAt: String = String(Int(Date().timeIntervalSince1970)) // Timestamp última modificación
    
    // MARK: - Claves de codificación
    enum CodingKeys: String, CodingKey {
        case id, name, colorHex, iconName, version, createdAt, updatedAt
    }
    
    // MARK: - Inicializador desde JSON (decodificación segura)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        version = (try? container.decode(Int.self, forKey: .version)) ?? 1
        colorHex = try? container.decode(String.self, forKey: .colorHex)
        iconName = try? container.decode(String.self, forKey: .iconName)
        
        // createdAt: soporta Date o timestamp Double/Int
        if let createdTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: createdTimestamp)
        } else if let createdTimestamp = try? container.decode(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: Double(createdTimestamp))
        } else {
            createdAt = (try? container.decode(Date.self, forKey: .createdAt)) ?? Date()
        }
        
        // updatedAt: soporta String o Double
        if let updatedTimestamp = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = String(Int(updatedTimestamp))
        } else if let updatedTimestamp = try? container.decode(Int.self, forKey: .updatedAt) {
            updatedAt = String(updatedTimestamp)
        } else {
            updatedAt = (try? container.decode(String.self, forKey: .updatedAt)) ?? "\(Int(Date().timeIntervalSince1970))"
        }
    }
    
    // MARK: - Inicializador manual mejorado
    init(id: UUID = UUID(),
         name: String,
         colorHex: String? = nil,
         iconName: String? = "folder",
         version: Int = 1,
         createdAt: Date = Date(),
         updatedAt: String = "\(Int(Date().timeIntervalSince1970))") {
        
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Propiedades computadas para UI
    var color: Color {
        if let hex = colorHex {
            return Color(hex: hex) ?? .blue
        }
        return .blue // Color por defecto
    }
    
    var icon: String {
        return iconName ?? "folder"
    }
    
    var displayName: String {
        return name.isEmpty ? "Sin nombre" : name
    }
    
    // MARK: - Métodos de utilidad
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Extensión para Color desde Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        switch length {
        case 6:
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        case 8:
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        default:
            return nil
        }
    }
}

// MARK: - Categorías predefinidas
extension Category {
    static let defaultCategories: [Category] = [
        Category(name: "Personal", colorHex: "007AFF", iconName: "person.circle"),
        Category(name: "Trabajo", colorHex: "34C759", iconName: "briefcase"),
        Category(name: "Salud", colorHex: "FF3B30", iconName: "heart"),
        Category(name: "Estudio", colorHex: "AF52DE", iconName: "book"),
        Category(name: "Hogar", colorHex: "FF9500", iconName: "house"),
        Category(name: "Compras", colorHex: "FFCC00", iconName: "cart"),
        Category(name: "Deporte", colorHex: "5856D6", iconName: "figure.run")
    ]
    
    static func defaultCategory() -> Category {
        return Category(name: "General", colorHex: "8E8E93", iconName: "star")
    }
}
