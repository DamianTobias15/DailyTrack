//
//  Reflection.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/7/25.
//  Version 2.0 - Fase 6: Modelo de Reflexiones Diarias
//  Last modified: 07/10/2025
//

import Foundation

/// Modelo de datos para reflexiones diarias
/// Compatible con Codable, Identifiable y Equatable para persistencia y UI
struct Reflection: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var mood: Int // 1-5 scale
    var tags: [String]
    let date: Date
    
    init(id: UUID = UUID(), text: String, mood: Int, tags: [String] = []) {
        self.id = id
        self.text = text
        self.mood = mood
        self.tags = tags
        self.date = Date()
    }
}

// MARK: - Extensiones de Utilidad
extension Reflection {
    /// Devuelve el emoji correspondiente al estado de ánimo
    var moodEmoji: String {
        switch mood {
        case 1: return "😔"
        case 2: return "😐"
        case 3: return "😊"
        case 4: return "😄"
        case 5: return "🤩"
        default: return "😊"
        }
    }
    
    /// Formatea la fecha para mostrar solo día/mes/año
    var dateOnlyString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
    
    /// Texto de preview (primeros 50 caracteres)
    var previewText: String {
        return String(text.prefix(50)) + (text.count > 50 ? "..." : "")
    }
}

// MARK: - Preview Data para desarrollo
#if DEBUG
extension Reflection {
    static let previewReflections = [
        Reflection(text: "Hoy fue un día muy productivo, completé todas mis tareas importantes.", mood: 4, tags: ["productivo", "éxito"]),
        Reflection(text: "Me costó concentrarme hoy, necesito mejorar mi enfoque mañana.", mood: 2, tags: ["enfoque", "mejora"]),
        Reflection(text: "¡Excelente día! Logré todos mis objetivos y aprendí algo nuevo.", mood: 5, tags: ["logro", "aprendizaje"])
    ]
}
#endif
