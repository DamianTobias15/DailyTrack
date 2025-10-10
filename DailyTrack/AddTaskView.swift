//
//  AddTaskView.swift
//  DailyTrack
//
//  Versión 3.0 - Fase 8: Soporte para creación de hábitos
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                habitConfigurationSection
                reminderSection
            }
            .navigationTitle(taskViewModel.isEditing ? "Editar Tarea" : "Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        taskViewModel.cancelEditing()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(taskViewModel.isEditing ? "Actualizar" : "Agregar") {
                        taskViewModel.saveTask()
                        dismiss()
                    }
                    .disabled(taskViewModel.taskTitle.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Secciones Descompuestas
    
    private var basicInfoSection: some View {
        Section(header: Text("Información de la Tarea")) {
            TextField("Título de la tarea", text: $taskViewModel.taskTitle)
            
            categoryPicker
            
            collaboratorPicker
        }
    }
    
    private var categoryPicker: some View {
        Picker("Categoría", selection: $taskViewModel.selectedCategory) {
            ForEach(taskViewModel.categories) { category in
                HStack {
                    // CORRECCIÓN: Usar valor por defecto para iconName opcional
                    Image(systemName: category.iconName ?? "folder")
                        .foregroundColor(colorFromHex(category.colorHex))
                    Text(category.name)
                }
                .tag(category as Category?)
            }
        }
    }
    
    private var collaboratorPicker: some View {
        Picker("Asignar a", selection: $taskViewModel.selectedCollaborator) {
            Text("Ninguno").tag(nil as Collaborator?)
            ForEach(taskViewModel.collaborators) { collaborator in
                Text(collaborator.name).tag(collaborator as Collaborator?)
            }
        }
    }
    
    private var habitConfigurationSection: some View {
        Section(header: Text("Configuración de Hábito")) {
            Toggle("Es un hábito", isOn: $taskViewModel.isHabit)
            
            if taskViewModel.isHabit {
                frequencyPicker
                habitDescription
            }
        }
    }
    
    private var frequencyPicker: some View {
        Picker("Frecuencia", selection: $taskViewModel.selectedHabitFrequency) {
            ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                Text(frequency.rawValue).tag(frequency)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var habitDescription: some View {
        Text("Los hábitos se renuevan automáticamente según su frecuencia y te ayudan a construir rachas.")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var reminderSection: some View {
        Section(header: Text("Recordatorio")) {
            DatePicker(
                "Fecha y hora",
                selection: Binding(
                    get: { taskViewModel.reminderDate ?? Date() },
                    set: { taskViewModel.reminderDate = $0 }
                ),
                in: Date()...
            )
            .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
    
    // MARK: - Helper Methods
    
    private func colorFromHex(_ hex: String?) -> Color {
        guard let hex = hex else { return .primary }
        
        // Implementación simple de conversión hex a Color
        switch hex {
        case "FF3B30": return .red
        case "FF9500": return .orange
        case "FFCC00": return .yellow
        case "4CD964": return .green
        case "5AC8FA": return .blue
        case "007AFF": return .blue
        case "5856D6": return .purple
        case "FF2D55": return .pink
        default: return .primary
        }
    }
}

// MARK: - Preview

#Preview {
    AddTaskView()
        .environmentObject(TaskViewModel.preview)
}
