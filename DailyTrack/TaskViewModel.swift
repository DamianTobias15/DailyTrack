//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez.
//  Version 3.0 - Fase 6: ViewModel completo con Tasks, Categories, Collaborators y Reflections
//  Last modified: 07/10/2025
//

import Foundation
import SwiftUI

/// ViewModel principal que gestiona el estado completo de la aplicación
/// Maneja Tasks, Categories, Collaborators y Reflections con persistencia en UserDefaults
class TaskViewModel: ObservableObject {
    
    // MARK: - Propiedades Publicadas para UI
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedCollaborator: Collaborator?
    @Published var reminderDate: Date?
    @Published var isEditing: Bool = false
    @Published var editingTask: Task?
    
    // MARK: - Datos Principales
    @Published var tasks: [Task] = []
    @Published var categories: [Category] = []
    @Published var collaborators: [Collaborator] = []
    @Published var reflections: [Reflection] = []
    
    // MARK: - Filtros y Búsqueda
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedCategoryFilter: UUID?
    
    // MARK: - Inicialización
    init() {
        loadAllData()
        setupDefaultData()
    }
    
    // MARK: - Carga y Configuración Inicial
    private func loadAllData() {
        loadTasks()
        loadCategories()
        loadCollaborators()
        loadReflections()
    }
    
    private func setupDefaultData() {
        // Configurar datos por defecto si están vacíos
        if categories.isEmpty {
            categories = Category.defaultCategories
            selectedCategory = categories.first
            saveCategories()
        }
        
        if collaborators.isEmpty {
            collaborators = Collaborator.sampleCollaborators
            selectedCollaborator = collaborators.first
            saveCollaborators()
        }
    }
    
    // MARK: - Persistencia: Tasks
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            let decoder = JSONDecoder()
            do {
                let decodedTasks = try decoder.decode([Task].self, from: data)
                DispatchQueue.main.async {
                    self.tasks = decodedTasks
                }
            } catch {
                print("❌ Error al cargar tareas: \(error)")
            }
        }
    }
    
    func saveTasks() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks")
        } catch {
            print("❌ Error al guardar tareas: \(error)")
        }
    }
    
    // MARK: - Persistencia: Categories
    func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "categories") {
            let decoder = JSONDecoder()
            do {
                let decodedCategories = try decoder.decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self.categories = decodedCategories
                }
            } catch {
                print("❌ Error al cargar categorías: \(error)")
            }
        }
    }
    
    func saveCategories() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(categories)
            UserDefaults.standard.set(data, forKey: "categories")
        } catch {
            print("❌ Error al guardar categorías: \(error)")
        }
    }
    
    // MARK: - Persistencia: Collaborators
    func loadCollaborators() {
        if let data = UserDefaults.standard.data(forKey: "collaborators") {
            let decoder = JSONDecoder()
            do {
                let decodedCollaborators = try decoder.decode([Collaborator].self, from: data)
                DispatchQueue.main.async {
                    self.collaborators = decodedCollaborators
                }
            } catch {
                print("❌ Error al cargar colaboradores: \(error)")
            }
        }
    }
    
    func saveCollaborators() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(collaborators)
            UserDefaults.standard.set(data, forKey: "collaborators")
        } catch {
            print("❌ Error al guardar colaboradores: \(error)")
        }
    }
    
    // MARK: - Persistencia: Reflections
    func loadReflections() {
        if let data = UserDefaults.standard.data(forKey: "reflections") {
            let decoder = JSONDecoder()
            do {
                let decodedReflections = try decoder.decode([Reflection].self, from: data)
                DispatchQueue.main.async {
                    self.reflections = decodedReflections
                }
            } catch {
                print("❌ Error al cargar reflexiones: \(error)")
            }
        }
    }
    
    func saveReflections() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(reflections)
            UserDefaults.standard.set(data, forKey: "reflections")
        } catch {
            print("❌ Error al guardar reflexiones: \(error)")
        }
    }
    
    // MARK: - Operaciones de Tasks
    
    /// Agrega una nueva tarea con parámetros opcionales
    func addTask(title: String, categoryId: UUID? = nil, assignedTo: UUID? = nil, reminderDate: Date? = nil) {
        let newTask = Task(
            title: title,
            categoryId: categoryId,
            assignedTo: assignedTo,
            reminderDate: reminderDate
        )
        tasks.append(newTask)
        saveTasks()
        print("✅ Tarea creada: \(title)")
    }
    
    /// Método alternativo para agregar objeto Task completo
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
        print("✅ Tarea creada: \(task.title)")
    }
    
    /// Actualiza una tarea existente
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            updateTaskDate(index: index)
            saveTasks()
            print("✅ Tarea actualizada: \(task.title)")
        }
    }
    
    /// Método principal para guardar tarea (compatibilidad con formulario)
    func saveTask() {
        guard !taskTitle.isEmpty else {
            print("❌ Error: el título de la tarea no puede estar vacío")
            return
        }
        
        if isEditing, let editingTask = editingTask {
            updateExistingTask(editingTask)
        } else {
            createNewTask()
        }
        
        clearTaskForm()
    }
    
    private func createNewTask() {
        let newTask = Task(
            title: taskTitle,
            categoryId: selectedCategory?.id,
            assignedTo: selectedCollaborator?.id,
            reminderDate: reminderDate
        )
        tasks.append(newTask)
        saveTasks()
        print("✅ Tarea creada: \(taskTitle)")
    }
    
    private func updateExistingTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = taskTitle
            tasks[index].categoryId = selectedCategory?.id
            tasks[index].assignedTo = selectedCollaborator?.id
            tasks[index].reminderDate = reminderDate
            updateTaskDate(index: index)
            saveTasks()
            print("✅ Tarea actualizada: \(taskTitle)")
        }
    }
    
    /// Prepara el formulario para editar una tarea
    func editTask(_ task: Task) {
        taskTitle = task.title
        selectedCategory = category(for: task.categoryId)
        selectedCollaborator = collaborator(for: task.assignedTo)
        reminderDate = task.reminderDate
        editingTask = task
        isEditing = true
    }
    
    /// Elimina tareas por índices
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    /// Elimina una tarea específica
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    /// Alterna el estado de completado de una tarea
    func toggleCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
            } else {
                tasks[index].completedAt = nil
            }
            updateTaskDate(index: index)
            saveTasks()
        }
    }
    
    /// Actualiza la fecha de modificación de una tarea
    private func updateTaskDate(index: Int) {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        tasks[index].updatedAt = timestamp
    }
    
    // MARK: - Operaciones de Categories
    
    func addCategory(name: String, colorHex: String? = nil, iconName: String? = "folder") {
        let newCategory = Category(name: name, colorHex: colorHex, iconName: iconName)
        categories.append(newCategory)
        saveCategories()
    }
    
    func category(for id: UUID?) -> Category? {
        categories.first { $0.id == id }
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        // Remover referencia de categoría en tareas
        for index in tasks.indices where tasks[index].categoryId == category.id {
            tasks[index].categoryId = nil
        }
        saveCategories()
        saveTasks()
    }
    
    // MARK: - Operaciones de Collaborators
    
    func collaborator(for id: UUID?) -> Collaborator? {
        collaborators.first { $0.id == id }
    }
    
    func addCollaborator(name: String, contactInfo: String? = nil, role: String? = nil) {
        let newCollaborator = Collaborator(name: name, contactInfo: contactInfo, role: role)
        collaborators.append(newCollaborator)
        saveCollaborators()
    }
    
    func deleteCollaborator(_ collaborator: Collaborator) {
        collaborators.removeAll { $0.id == collaborator.id }
        // Remover referencia de colaborador en tareas
        for index in tasks.indices where tasks[index].assignedTo == collaborator.id {
            tasks[index].assignedTo = nil
        }
        saveCollaborators()
        saveTasks()
    }
    
    // MARK: - Operaciones de Reflections
    
    /// Agrega una nueva reflexión
    func addReflection(text: String, mood: Int = 3, tags: [String] = []) {
        let newReflection = Reflection(text: text, mood: mood, tags: tags)
        reflections.append(newReflection)
        saveReflections()
        print("✅ Reflexión guardada")
    }
    
    /// Actualiza una reflexión existente
    func updateReflection(_ reflection: Reflection) {
        if let index = reflections.firstIndex(where: { $0.id == reflection.id }) {
            reflections[index] = reflection
            saveReflections()
        }
    }
    
    /// Elimina una reflexión
    func deleteReflection(_ reflection: Reflection) {
        reflections.removeAll { $0.id == reflection.id }
        saveReflections()
    }
    
    /// Obtiene reflexiones para una fecha específica
    func reflectionsForDate(_ date: Date) -> [Reflection] {
        let calendar = Calendar.current
        return reflections.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Utilidades de UI
    
    func clearTaskForm() {
        taskTitle = ""
        taskDescription = ""
        selectedCategory = categories.first
        selectedCollaborator = collaborators.first
        reminderDate = nil
        isEditing = false
        editingTask = nil
    }
    
    func cancelEditing() {
        clearTaskForm()
    }
    
    // MARK: - Filtros y Búsquedas
    
    var filteredTasks: [Task] {
        var filtered = tasks
        
        // Filtro por estado
        switch selectedFilter {
        case .all:
            break
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .pending:
            filtered = filtered.filter { !$0.isCompleted }
        case .withReminders:
            filtered = filtered.filter { $0.reminderDate != nil }
        }
        
        // Filtro por categoría
        if let categoryId = selectedCategoryFilter {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }
        
        // Búsqueda por texto
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.categoryId != nil && category(for: task.categoryId)?.name.localizedCaseInsensitiveContains(searchText) == true) ||
                (task.assignedTo != nil && collaborator(for: task.assignedTo)?.name.localizedCaseInsensitiveContains(searchText) == true)
            }
        }
        
        return filtered
    }
    
    func tasksForCategory(_ categoryId: UUID) -> [Task] {
        tasks.filter { $0.categoryId == categoryId }
    }
    
    func tasksForCollaborator(_ collaboratorId: UUID) -> [Task] {
        tasks.filter { $0.assignedTo == collaboratorId }
    }
    
    // MARK: - Estadísticas y Métricas
    
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter(\.isCompleted).count
        return Double(completed) / Double(tasks.count)
    }
    
    func weeklyStats() -> [Int] {
        var stats = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        
        for task in tasks {
            if task.isCompleted, let date = task.completedAt {
                let weekday = calendar.component(.weekday, from: date) - 1
                stats[weekday] += 1
            }
        }
        return stats
    }
    
    func categoryStats() -> [(category: Category, count: Int, completed: Int)] {
        var stats: [(Category, Int, Int)] = []
        
        for category in categories {
            let categoryTasks = tasks.filter { $0.categoryId == category.id }
            let total = categoryTasks.count
            let completed = categoryTasks.filter { $0.isCompleted }.count
            stats.append((category, total, completed))
        }
        
        return stats.sorted { $0.1 > $1.1 }
    }
    
    func collaboratorStats() -> [(collaborator: Collaborator, count: Int, completed: Int)] {
        var stats: [(Collaborator, Int, Int)] = []
        
        for collaborator in collaborators {
            let collaboratorTasks = tasks.filter { $0.assignedTo == collaborator.id }
            let total = collaboratorTasks.count
            let completed = collaboratorTasks.filter { $0.isCompleted }.count
            stats.append((collaborator, total, completed))
        }
        
        return stats.sorted { $0.1 > $1.1 }
    }
}

// MARK: - Enums de Apoyo

/// Filtros disponibles para las tareas
enum TaskFilter: String, CaseIterable {
    case all = "Todas"
    case completed = "Completadas"
    case pending = "Pendientes"
    case withReminders = "Con Recordatorios"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .completed: return "checkmark.circle"
        case .pending: return "circle"
        case .withReminders: return "bell"
        }
    }
}

// MARK: - Preview Provider para Desarrollo

#if DEBUG
extension TaskViewModel {
    static var preview: TaskViewModel {
        let viewModel = TaskViewModel()
        
        // Agregar datos de ejemplo para previews
        viewModel.tasks = [
            Task(title: "Reunión de equipo", categoryId: viewModel.categories.first?.id),
            Task(title: "Hacer ejercicio", isCompleted: true, categoryId: viewModel.categories[1].id),
            Task(title: "Comprar víveres", categoryId: viewModel.categories[1].id, assignedTo: viewModel.collaborators.first?.id)
        ]
        
        // Agregar reflexiones de ejemplo
        viewModel.reflections = [
            Reflection(text: "Hoy fue un día muy productivo", mood: 4, tags: ["productivo", "éxito"]),
            Reflection(text: "Me siento motivado para la semana", mood: 5, tags: ["motivación"])
        ]
        
        return viewModel
    }
}
#endif
