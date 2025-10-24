//
//  CollaboratorsManagementView.swift
//  DailyTrack
//
//  CORREGIDO: Eliminado NavigationView duplicado
//  Versión: 1.2 - Bug de headers duplicados resuelto
//

import SwiftUI

struct CollaboratorsManagementView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newCollaboratorName = ""
    @State private var newCollaboratorRole = ""
    @State private var newCollaboratorContact = ""
    @State private var showingAddForm = false
    @State private var editingCollaborator: Collaborator?
    
    var body: some View {
        // ⚠️ ELIMINADO: NavigationView duplicado - Ya viene de ContentView
        VStack {
            if taskVM.collaborators.isEmpty {
                emptyStateView
            } else {
                collaboratorsListView
            }
        }
        .navigationTitle("Gestión de Colaboradores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Listo") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            collaboratorFormView
        }
        .sheet(item: $editingCollaborator) { collaborator in
            collaboratorFormView(editing: collaborator)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay colaboradores")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Agrega colaboradores para poder asignarles tareas")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingAddForm = true
            } label: {
                Label("Agregar Primer Colaborador", systemImage: "person.badge.plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
    
    // MARK: - Collaborators List
    private var collaboratorsListView: some View {
        List {
            Section(header: Text("Colaboradores (\(taskVM.collaborators.count))")) {
                ForEach(taskVM.collaborators) { collaborator in
                    HStack {
                        Circle()
                            .fill(colorForCollaborator(collaborator))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(initialsForCollaborator(collaborator))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(collaborator.name)
                                .font(.headline)
                            
                            if let role = collaborator.role, !role.isEmpty {
                                Text(role)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let contact = collaborator.contactInfo, !contact.isEmpty {
                                Text(contact)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        // Indicador de tareas asignadas
                        let assignedTasks = taskVM.tasksForCollaborator(collaborator.id).count
                        if assignedTasks > 0 {
                            Text("\(assignedTasks)")
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCollaborator = collaborator
                    }
                }
                .onDelete(perform: deleteCollaborators)
            }
            
            Section {
                Button {
                    showingAddForm = true
                } label: {
                    Label("Agregar Nuevo Colaborador", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // ... (el resto del código permanece igual)
    // MARK: - Form Views
    private var collaboratorFormView: some View {
        collaboratorFormView(editing: nil)
    }
    
    private func collaboratorFormView(editing collaborator: Collaborator?) -> some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre completo", text: $newCollaboratorName)
                    TextField("Rol o puesto (opcional)", text: $newCollaboratorRole)
                    TextField("Contacto (email/tel, opcional)", text: $newCollaboratorContact)
                }
                
                if let collaborator = collaborator {
                    Section {
                        Button("Eliminar Colaborador", role: .destructive) {
                            deleteCollaborator(collaborator)
                        }
                    }
                }
            }
            .navigationTitle(collaborator == nil ? "Nuevo Colaborador" : "Editar Colaborador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        if collaborator == nil {
                            showingAddForm = false
                        } else {
                            editingCollaborator = nil
                        }
                        clearForm()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(collaborator == nil ? "Agregar" : "Guardar") {
                        saveCollaborator(editing: collaborator)
                    }
                    .disabled(newCollaboratorName.isEmpty)
                }
            }
            .onAppear {
                if let collaborator = collaborator {
                    newCollaboratorName = collaborator.name
                    newCollaboratorRole = collaborator.role ?? ""
                    newCollaboratorContact = collaborator.contactInfo ?? ""
                }
            }
        }
    }
    
    // MARK: - Data Management Methods
    private func saveCollaborator(editing collaborator: Collaborator?) {
        let name = newCollaboratorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let role = newCollaboratorRole.trimmingCharacters(in: .whitespacesAndNewlines)
        let contact = newCollaboratorContact.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let collaborator = collaborator {
            // Modificar colaborador existente
            if let index = taskVM.collaborators.firstIndex(where: { $0.id == collaborator.id }) {
                taskVM.collaborators[index].name = name
                taskVM.collaborators[index].role = role.isEmpty ? nil : role
                taskVM.collaborators[index].contactInfo = contact.isEmpty ? nil : contact
                taskVM.saveCollaborators()
            }
            editingCollaborator = nil
        } else {
            // Agregar nuevo colaborador
            taskVM.addCollaborator(
                name: name,
                contactInfo: contact.isEmpty ? nil : contact,
                role: role.isEmpty ? nil : role
            )
            showingAddForm = false
        }
        clearForm()
    }
    
    private func deleteCollaborators(at offsets: IndexSet) {
        for index in offsets {
            let collaborator = taskVM.collaborators[index]
            deleteCollaborator(collaborator)
        }
    }
    
    private func deleteCollaborator(_ collaborator: Collaborator) {
        taskVM.deleteCollaborator(collaborator)
        if editingCollaborator?.id == collaborator.id {
            editingCollaborator = nil
        }
    }
    
    private func clearForm() {
        newCollaboratorName = ""
        newCollaboratorRole = ""
        newCollaboratorContact = ""
    }
    
    // MARK: - UI Helper Methods
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

// MARK: - Preview
struct CollaboratorsManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CollaboratorsManagementView()
        }
        .environmentObject(TaskViewModel.preview)
    }
}
