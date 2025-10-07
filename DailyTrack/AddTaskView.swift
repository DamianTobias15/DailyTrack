//
//  AddTaskView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/7/25.
//  Version 2.0 - Fase 6: Compatible con TaskViewModel actualizado
//  Last modified: \(Date())
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskVM: TaskViewModel
    
    // MARK: - Estados locales para el formulario
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategoryId: UUID?
    @State private var selectedCollaboratorId: UUID?
    @State private var reminderDate = Date()
    @State private var hasReminder = false
    
    // MARK: - Propiedades computadas
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var selectedCategory: Category? {
        taskVM.categories.first { $0.id == selectedCategoryId }
    }
    
    private var selectedCollaborator: Collaborator? {
        taskVM.collaborators.first { $0.id == selectedCollaboratorId }
    }
    
    // MARK: - Cuerpo principal
    var body: some View {
        NavigationView {
            Form {
                taskDetailsSection
                categorySection
                collaboratorSection
                reminderSection
            }
            .navigationTitle(taskVM.isEditing ? "Editar Tarea" : "Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        taskVM.cancelEditing()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(taskVM.isEditing ? "Actualizar" : "Agregar") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                setupFormForEditing()
            }
        }
    }
    
    // MARK: - Secciones del formulario
    private var taskDetailsSection: some View {
        Section(header: Text("Detalles de la tarea")) {
            TextField("Título de la tarea", text: $title)
                .textInputAutocapitalization(.sentences)
            
            TextField("Descripción (opcional)", text: $description)
                .textInputAutocapitalization(.sentences)
        }
    }
    
    private var categorySection: some View {
        Section(header: Text("Categoría")) {
            Picker("Categoría", selection: $selectedCategoryId) {
                Text("Sin categoría").tag(nil as UUID?)
                ForEach(taskVM.categories) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .frame(width: 25)
                        Text(category.name)
                    }
                    .tag(category.id as UUID?)
                }
            }
            .pickerStyle(.navigationLink)
            
            if let category = selectedCategory {
                HStack {
                    Text("Color:")
                    Spacer()
                    Circle()
                        .fill(category.color)
                        .frame(width: 20, height: 20)
                    Text(category.name)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    private var collaboratorSection: some View {
        Section(header: Text("Asignación")) {
            Picker("Asignar a", selection: $selectedCollaboratorId) {
                Text("Nadie").tag(nil as UUID?)
                ForEach(taskVM.collaborators) { collaborator in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(collaborator.avatarColor)
                                .frame(width: 25, height: 25)
                            Text(collaborator.initials)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading) {
                            Text(collaborator.name)
                            if let role = collaborator.role {
                                Text(role)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tag(collaborator.id as UUID?)
                }
            }
            .pickerStyle(.navigationLink)
            
            if let collaborator = selectedCollaborator {
                HStack {
                    Text("Contacto:")
                    Spacer()
                    if let contact = collaborator.contactInfo {
                        Link(contact, destination: URL(string: collaborator.isEmail ? "mailto:\(contact)" : "tel:\(contact)")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else {
                        Text("Sin contacto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var reminderSection: some View {
        Section(header: Text("Recordatorio")) {
            Toggle("Activar recordatorio", isOn: $hasReminder)
            
            if hasReminder {
                DatePicker("Fecha y hora", selection: $reminderDate, in: Date()...)
                    .datePickerStyle(.compact)
                
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("Recordatorio activo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Métodos
    private func setupFormForEditing() {
        if taskVM.isEditing, let editingTask = taskVM.editingTask {
            title = editingTask.title
            selectedCategoryId = editingTask.categoryId
            selectedCollaboratorId = editingTask.assignedTo
            
            if let reminder = editingTask.reminderDate {
                reminderDate = reminder
                hasReminder = true
            }
        } else {
            // Valores por defecto para nueva tarea
            selectedCategoryId = taskVM.categories.first?.id
            selectedCollaboratorId = taskVM.collaborators.first?.id
            reminderDate = Date().addingTimeInterval(3600) // 1 hora por defecto
        }
    }
    
    private func saveTask() {
        let finalReminderDate = hasReminder ? reminderDate : nil
        
        if taskVM.isEditing {
            // Actualizar tarea existente
            if var editingTask = taskVM.editingTask {
                editingTask.title = title
                editingTask.categoryId = selectedCategoryId
                editingTask.assignedTo = selectedCollaboratorId
                editingTask.reminderDate = finalReminderDate
                editingTask.updatedAt = "\(Int(Date().timeIntervalSince1970))"
                
                taskVM.updateTask(editingTask)
            }
        } else {
            // Crear nueva tarea usando el método del ViewModel
            taskVM.addTask(
                title: title,
                categoryId: selectedCategoryId,
                assignedTo: selectedCollaboratorId,
                reminderDate: finalReminderDate
            )
        }
        
        // Limpiar el formulario después de guardar
        resetForm()
    }
    
    private func resetForm() {
        title = ""
        description = ""
        selectedCategoryId = taskVM.categories.first?.id
        selectedCollaboratorId = taskVM.collaborators.first?.id
        reminderDate = Date().addingTimeInterval(3600)
        hasReminder = false
    }
}

// MARK: - Vista previa
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskViewModel.preview)
    }
}
