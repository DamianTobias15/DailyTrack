import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var categoryId: UUID?
    var assignedTo: UUID?
    var reminderDate: Date?
    var reminderMessage: String?
    var sendWhatsApp: Bool = false
    var whatsappNumber: String?
}
