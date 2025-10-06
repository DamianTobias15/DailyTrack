import Foundation

/// Modelo de tarea
struct Task: Codable, Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: String
    var updatedAt: String
    var version: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, updatedAt, version
    }
    
    /// Decodificación segura: soporta String o Double en fechas
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        version = try container.decode(Int.self, forKey: .version)
        
        // createdAt: puede ser String o Double
        if let createdTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = String(Int(createdTimestamp))
        } else {
            createdAt = try container.decode(String.self, forKey: .createdAt)
        }
        
        // updatedAt: puede ser String o Double
        if let updatedTimestamp = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = String(Int(updatedTimestamp))
        } else {
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
        }
    }
    
    /// Init manual para crear tareas desde Swift
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: String = "\(Int(Date().timeIntervalSince1970))", updatedAt: String = "\(Int(Date().timeIntervalSince1970))", version: Int = 1) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
    }
}
