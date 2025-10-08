//
//  TaskAssignmentView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez.
//  Versión: 1.0 - Modificación de asignaciones de tareas
//  Last modified: 07/10/2025
//

import SwiftUI

struct TaskAssignmentView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCollaboratorId: UUID?
    @State private var showingCollaboratorsManagement = false
    
    var body: some View {
        NavigationView {
            Form {
                currentAssignmentSection
                collaboratorsListSection
                manageCollaboratorsSection
            }
            .navigationTitle("Asignar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAssignment()
                    }
                    .disabled(!hasChanges)
                }
            }
            .sheet(isPresented: $showingCollaboratorsManagement) {
                CollaboratorsManagementView()
                    .environmentObject(taskVM)
            }
            .onAppear {
                selectedCollaboratorId = task.assignedTo
            }
        }
    }
    
    private var hasChanges: Bool {
        selectedCollaboratorId != task.assignedTo
    }
    
    private var currentAssignmentSection: some View {
        Section(header: Text("Asignación Actual")) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tarea:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(task.title)
                        .font(.body)
                }
                
                Spacer()
                
                if let currentCollaborator = taskVM.collaborator(for: task.assignedTo) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Asignado a:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(currentCollaborator.name)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                } else {
                    Text("Sin asignar")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var collaboratorsListSection: some View {
        Section(header: Text("Seleccionar Colaborador")) {
            // Opción "Sin asignar"
            Button {
                selectedCollaboratorId = nil
            } label: {
                HStack {
                    Image(systemName: selectedCollaboratorId == nil ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedCollaboratorId == nil ? .blue : .gray)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sin asignar")
                            .foregroundColor(.primary)
                        Text("No asignar a nadie")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Lista de colaboradores
            ForEach(taskVM.collaborators) { collaborator in
                Button {
                    selectedCollaboratorId = collaborator.id
                } label: {
                    HStack {
                        Image(systemName: selectedCollaboratorId == collaborator.id ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedCollaboratorId == collaborator.id ? .blue : .gray)
                        
                        Circle()
                            .fill(colorForCollaborator(collaborator))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(initialsForCollaborator(collaborator))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(collaborator.name)
                                .foregroundColor(.primary)
                            
                            if let role = collaborator.role, !role.isEmpty {
                                Text(role)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            let taskCount = taskVM.tasksForCollaborator(collaborator.id).count
                            Text("\(taskCount) tarea(s) asignada(s)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var manageCollaboratorsSection: some View {
        Section {
            Button {
                showingCollaboratorsManagement = true
            } label: {
                Label("Gestionar Colaboradores", systemImage: "person.2.circle.fill")
                    .foregroundColor(.blue)
            }
            
            if taskVM.collaborators.isEmpty {
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No hay colaboradores")
                        .font(.headline)
                    
                    Text("Agrega colaboradores para poder asignarles tareas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showingCollaboratorsManagement = true
                    } label: {
                        Text("Agregar Primer Colaborador")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func saveAssignment() {
        // Actualizar la tarea con la nueva asignación
        if var updatedTask = taskVM.tasks.first(where: { $0.id == task.id }) {
            updatedTask.assignedTo = selectedCollaboratorId
            taskVM.updateTask(updatedTask)
        }
        dismiss()
    }
    
    private func colorForCollaborator(_ collaborator: Collaborator) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .indigo]
        let index = abs(collaborator.id.hashValue) % colors.count
        return colors[index]
    }
    
    private func initialsForCollaborator(_ collaborator: Collaborator) -> String {
        let components = collaborator.name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined().uppercased()
    }
}

struct TaskAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        let taskVM = TaskViewModel.preview
        let sampleTask = taskVM.tasks[0]
        
        TaskAssignmentView(task: sampleTask)
            .environmentObject(taskVM)
    }
}
