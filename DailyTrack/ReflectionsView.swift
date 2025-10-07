//
//  ReflectionsView.swift
//  DailyTrack
//
//
//  Created by Erick Damian Tobias Valdez on 10/7/25.
//  Version 2.0 - Fase 6: Vista de Reflexiones Diarias
//  Last modified: 07/10/2025
//

import SwiftUI

/// Vista principal para gestionar reflexiones diarias
/// Permite registrar estado de ánimo y reflexiones del día
struct ReflectionsView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var reflectionText = ""
    @State private var selectedMood = 3
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            Form {
                moodSelectionSection
                reflectionInputSection
                
                if !taskVM.reflections.isEmpty {
                    recentReflectionsSection
                }
            }
            .navigationTitle("Reflexión Diaria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .sheet(isPresented: $showingHistory) {
                ReflectionsHistoryView()
            }
        }
    }
}

// MARK: - Secciones de la Vista
private extension ReflectionsView {
    
    var moodSelectionSection: some View {
        Section(header: Text("Estado de ánimo")) {
            VStack(alignment: .leading, spacing: 12) {
                Text("¿Cómo te sientes hoy?")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { mood in
                        moodButton(mood: mood)
                    }
                }
                
                Text(moodDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
    }
    
    var reflectionInputSection: some View {
        Section(header: Text("Reflexión del día")) {
            VStack(alignment: .leading) {
                Text("Comparte tus pensamientos, logros o aprendizajes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                TextEditor(text: $reflectionText)
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    Text("\(reflectionText.count)/500 caracteres")
                        .font(.caption)
                        .foregroundColor(reflectionText.count > 500 ? .red : .secondary)
                    
                    Spacer()
                    
                    if reflectionText.count > 500 {
                        Text("Límite excedido")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
    }
    
    var recentReflectionsSection: some View {
        Section(header: HStack {
            Text("Reflexiones recientes")
            Spacer()
            Button("Ver todas") {
                showingHistory = true
            }
            .font(.caption)
        }) {
            ForEach(Array(taskVM.reflections.prefix(3))) { reflection in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(reflection.moodEmoji)
                            .font(.title3)
                        Text(reflection.dateOnlyString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Text(reflection.previewText)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    var cancelButton: some View {
        Button("Cancelar") {
            dismiss()
        }
    }
    
    var saveButton: some View {
        Button("Guardar") {
            saveReflection()
        }
        .disabled(reflectionText.isEmpty || reflectionText.count > 500)
    }
}

// MARK: - Componentes de UI
private extension ReflectionsView {
    
    func moodButton(mood: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
        } label: {
            Text(moodEmoji(mood))
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    selectedMood == mood ?
                    Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            selectedMood == mood ? Color.blue : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var moodDescription: String {
        switch selectedMood {
        case 1: return "No tan bien - Tu día fue difícil"
        case 2: return "Regular - Hubo altibajos"
        case 3: return "Bien - Un día normal y tranquilo"
        case 4: return "Muy bien - Día productivo y positivo"
        case 5: return "Excelente - ¡Día increíble!"
        default: return "Selecciona cómo te sientes"
        }
    }
    
    func moodEmoji(_ mood: Int) -> String {
        switch mood {
        case 1: return "😔"
        case 2: return "😐"
        case 3: return "😊"
        case 4: return "😄"
        case 5: return "🤩"
        default: return "😊"
        }
    }
}

// MARK: - Funciones de Acción
private extension ReflectionsView {
    
    func saveReflection() {
        guard !reflectionText.isEmpty && reflectionText.count <= 500 else { return }
        
        taskVM.addReflection(
            text: reflectionText.trimmingCharacters(in: .whitespacesAndNewlines),
            mood: selectedMood,
            tags: extractTags(from: reflectionText)
        )
        
        // Efecto de confirmación
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    func extractTags(from text: String) -> [String] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let potentialTags = words.filter { word in
            word.count > 3 && word.count < 15 && !word.contains("@")
        }
        return Array(potentialTags.prefix(3))
    }
}

// MARK: - Vista de Historial (Sheet)
struct ReflectionsHistoryView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if taskVM.reflections.isEmpty {
                    emptyStateView
                } else {
                    ForEach(taskVM.reflections.sorted(by: { $0.date > $1.date })) { reflection in
                        reflectionRow(reflection)
                    }
                    .onDelete(perform: deleteReflection)
                }
            }
            .navigationTitle("Historial de Reflexiones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No hay reflexiones aún")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Comienza agregando tu primera reflexión desde la vista principal")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func reflectionRow(_ reflection: Reflection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reflection.moodEmoji)
                    .font(.title2)
                Text(reflection.dateOnlyString)
                    .font(.headline)
                Spacer()
            }
            
            Text(reflection.text)
                .font(.body)
                .foregroundColor(.primary)
            
            if !reflection.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(reflection.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func deleteReflection(at offsets: IndexSet) {
        for index in offsets {
            let reflection = taskVM.reflections.sorted(by: { $0.date > $1.date })[index]
            taskVM.deleteReflection(reflection)
        }
    }
}

// MARK: - Previews
struct ReflectionsView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionsView()
            .environmentObject(TaskViewModel())
        
        ReflectionsHistoryView()
            .environmentObject(TaskViewModel())
    }
}
