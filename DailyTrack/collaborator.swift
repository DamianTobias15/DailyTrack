//
//  Collaborator.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//  Version 2.0 - Fase 6: Modelo de Colaboradores con soporte mejorado para UI
//  Last modified: \(Date())
//

import Foundation
import SwiftUI

/// Modelo de Colaborador mejorado con soporte para UI
/// Compatible con Codable, Identifiable y Hashable
struct Collaborator: Codable, Identifiable, Hashable {
    
    // MARK: - Propiedades principales
    let id: UUID
    var name: String                     // Nombre del colaborador
    var contactInfo: String?             // Email o teléfono
    var avatarColorHex: String?          // Color para el avatar (nuevo)
    var role: String?                    // Rol o posición (nuevo)
    var version: Int                     // Versión del modelo
    var createdAt: Date = Date()         // Fecha de creación
    var updatedAt: String = String(Int(Date().timeIntervalSince1970)) // Timestamp última modificación
    
    // MARK: - Claves de codificación
    enum CodingKeys: String, CodingKey {
        case id, name, contactInfo, avatarColorHex, role, version, createdAt, updatedAt
    }
    
    // MARK: - Inicializador desde JSON (decodificación segura)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        version = (try? container.decode(Int.self, forKey: .version)) ?? 1
        contactInfo = try? container.decode(String.self, forKey: .contactInfo)
        avatarColorHex = try? container.decode(String.self, forKey: .avatarColorHex)
        role = try? container.decode(String.self, forKey: .role)
        
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
         contactInfo: String? = nil,
         avatarColorHex: String? = nil,
         role: String? = nil,
         version: Int = 1,
         createdAt: Date = Date(),
         updatedAt: String = "\(Int(Date().timeIntervalSince1970))") {
        
        self.id = id
        self.name = name
        self.contactInfo = contactInfo
        self.avatarColorHex = avatarColorHex
        self.role = role
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Propiedades computadas para UI
    var avatarColor: Color {
        if let hex = avatarColorHex {
            return Color(hex: hex) ?? generateColorFromName()
        }
        return generateColorFromName()
    }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        } else {
            // Fallback: toma las primeras letras de cada palabra
            let words = name.components(separatedBy: .whitespaces)
            let firstLetters = words.prefix(2).compactMap { $0.first }
            return String(firstLetters).uppercased()
        }
    }
    
    var displayName: String {
        return name.isEmpty ? "Sin nombre" : name
    }
    
    var displayRole: String {
        return role ?? "Sin rol asignado"
    }
    
    var isEmail: Bool {
        guard let contact = contactInfo else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: contact)
    }
    
    var isPhone: Bool {
        guard let contact = contactInfo else { return false }
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: contact)
    }
    
    var contactType: String {
        if isEmail { return "Email" }
        if isPhone { return "Teléfono" }
        return "Contacto"
    }
    
    var contactIcon: String {
        if isEmail { return "envelope" }
        if isPhone { return "phone" }
        return "person"
    }
    
    // MARK: - Métodos de utilidad
    private func generateColorFromName() -> Color {
        // Genera un color consistente basado en el nombre
        var hash = 0
        for character in name {
            hash = Int(character.unicodeScalars.first!.value) + ((hash << 5) - hash)
        }
        
        let colors: [Color] = [.red, .green, .blue, .orange, .purple, .teal, .pink, .indigo]
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Collaborator, rhs: Collaborator) -> Bool {
        lhs.id == rhs.id
    }
    
    // Validación de datos
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Colaboradores predefinidos
extension Collaborator {
    static let sampleCollaborators: [Collaborator] = [
        Collaborator(
            name: "Christiano Ronals",
            contactInfo: "CR7@email.com",
            avatarColorHex: "FF3B30",
            role: "Desarrolladora"
        ),
        Collaborator(
            name: "Paola Baena",
            contactInfo: "pao@email.com",
            avatarColorHex: "007AFF",
            role: "Diseñador"
        ),
        Collaborator(
            name: "Damian Tobias",
            contactInfo: "dam@email.com",
            avatarColorHex: "34C759",
            role: "Project Manager"
        ),
        Collaborator(
            name: "Maya mayukis",
            contactInfo: "+1234567890",
            avatarColorHex: "FF9500",
            role: "QA Tester"
        ),
        Collaborator(
            name: "Bruce Wayne",
            contactInfo: "Wayne@email.com",
            avatarColorHex: "AF52DE",
            role: "DevOps"
        )
    ]
    
    static func defaultCollaborator() -> Collaborator {
        return Collaborator(name: "Sin asignar", avatarColorHex: "8E8E93")
    }
    
    static func me() -> Collaborator {
        return Collaborator(
            name: "Yo",
            contactInfo: nil,
            avatarColorHex: "007AFF",
            role: "Propietario"
        )
    }
}

// MARK: - Función de utilidad para PersonNameComponentsFormatter
extension String {
    func extractInitials() -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: self) {
            var initials = ""
            if let given = components.givenName?.first { initials.append(given) }
            if let family = components.familyName?.first { initials.append(family) }
            return initials.isEmpty ? String(prefix(2)).uppercased() : initials.uppercased()
        }
        return String(prefix(2)).uppercased()
    }
}
