//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez.
//  Version 4.0 - Fase 8: ViewModel completo con Sistema de Hábitos
//  Last modified: 09/10/2025
//

import Foundation
import SwiftUI

/// ViewModel principal que gestiona el estado completo de la aplicación
/// Maneja Tasks, Categories, Collaborators, Reflections y Hábitos con persistencia en UserDefaults
class TaskViewModel: ObservableObject {
    
    // MARK: - Propiedades Publicadas para UI
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedCollaborator: Collaborator?
    @Published var reminderDate: Date?
    @Published var isEditing: Bool = false
    @Published var editingTask: Task?
    
    // MARK: - Fase 8: Propiedades para Hábitos
    @Published var isHabit: Bool = false
    @Published var selectedHabitFrequency: HabitFrequency = .daily
    
    // MARK: - Datos Principales
    @Published var tasks: [Task] = []
    @Published var categories: [Category] = []
    @Published var collaborators: [Collaborator] = []
    @Published var reflections: [Reflection] = []
    
    // MARK: - Filtros y Búsqueda
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedCategoryFilter: UUID?
    
    // MARK: - Servicios
    private let habitService = HabitService()
    
    // MARK: - Inicialización
    init() {
        loadAllData()
        setupDefaultData()
        setupHabitSystem() // Fase 8: Inicializar sistema de hábitos
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
    
    // MARK: - Fase 8: Sistema de Hábitos
    private func setupHabitSystem() {
        habitService.updateHabits(from: tasks)
        autoRenewHabits() // Verificar autorrenovación al iniciar
    }
    
    /// Realiza la autorrenovación de hábitos
    func autoRenewHabits() {
        habitService.autoRenewHabits(tasks: &tasks)
        habitService.updateHabits(from: tasks)
        saveTasks()
    }
    
    /// Completar un hábito con lógica especial de rachas
    func completeHabit(_ task: Task) {
        guard var updatedTask = tasks.first(where: { $0.id == task.id }) else { return }
        
        if !updatedTask.isCompleted {
            updatedTask.incrementStreak()
            tasks = tasks.map { $0.id == task.id ? updatedTask : $0 }
            habitService.updateHabits(from: tasks)
            saveTasks()
            
            print("✅ Hábito completado: \(task.title) - Nueva racha: \(updatedTask.habitStreak)")
        }
    }
    
    /// Obtiene todos los hábitos
    var habits: [Task] {
        habitService.habits
    }
    
    /// Genera reporte de hábitos
    func generateHabitReport() -> HabitReport {
        habitService.generateHabitReport()
    }
    
    /// Hábitos por frecuencia específica
    func habitsByFrequency(_ frequency: HabitFrequency) -> [Task] {
        habitService.habitsByFrequency(frequency)
    }
    
    /// Hábitos que necesitan atención
    func habitsNeedingAttention() -> [Task] {
        habitService.habitsNeedingAttention()
    }
    
    /// Hábitos con mejor racha
    func topHabitsByStreak(limit: Int = 5) -> [Task] {
        habitService.topHabitsByStreak(limit: limit)
    }
    
    // MARK: - Persistencia: Tasks
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            let decoder = JSONDecoder()
            do {
                let decodedTasks = try decoder.decode([Task].self, from: data)
                DispatchQueue.main.async {
                    self.tasks = decodedTasks
                    // Fase 8: Actualizar servicio de hábitos
                    self.habitService.updateHabits(from: self.tasks)
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
    func addTask(title: String, categoryId: UUID? = nil, assignedTo: UUID? = nil, reminderDate: Date? = nil, isHabit: Bool = false, habitFrequency: HabitFrequency = .daily) {
        let newTask = Task(
            title: title,
            categoryId: categoryId,
            assignedTo: assignedTo,
            reminderDate: reminderDate,
            isHabit: isHabit,
            habitFrequency: habitFrequency
        )
        tasks.append(newTask)
        habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
        saveTasks()
        print("✅ Tarea creada: \(title)" + (isHabit ? " (Hábito \(habitFrequency.rawValue))" : ""))
    }
    
    /// Método alternativo para agregar objeto Task completo
    func addTask(_ task: Task) {
        tasks.append(task)
        habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
        saveTasks()
        print("✅ Tarea creada: \(task.title)")
    }
    
    /// Actualiza una tarea existente
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            updateTaskDate(index: index)
            habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
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
            reminderDate: reminderDate,
            isHabit: isHabit,
            habitFrequency: selectedHabitFrequency
        )
        tasks.append(newTask)
        habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
        saveTasks()
        print("✅ Tarea creada: \(taskTitle)" + (isHabit ? " (Hábito \(selectedHabitFrequency.rawValue))" : ""))
    }
    
    private func updateExistingTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = taskTitle
            tasks[index].categoryId = selectedCategory?.id
            tasks[index].assignedTo = selectedCollaborator?.id
            tasks[index].reminderDate = reminderDate
            // Fase 8: Actualizar propiedades de hábito
            tasks[index].isHabit = isHabit
            tasks[index].habitFrequency = selectedHabitFrequency
            if isHabit && tasks[index].habitStartDate == nil {
                tasks[index].habitStartDate = Date()
            }
            
            updateTaskDate(index: index)
            habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
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
        // Fase 8: Propiedades de hábito
        isHabit = task.isHabit
        selectedHabitFrequency = task.habitFrequency
        editingTask = task
        isEditing = true
    }
    
    /// Elimina tareas por índices
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
        saveTasks()
    }
    
    /// Elimina una tarea específica
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
        saveTasks()
    }
    
    /// Alterna el estado de completado de una tarea
    func toggleCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            let wasCompleted = tasks[index].isCompleted
            tasks[index].isCompleted.toggle()
            
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
                // Fase 8: Si es hábito, manejar racha
                if tasks[index].isHabit && !wasCompleted {
                    tasks[index].incrementStreak()
                    print("🔥 Hábito '\(task.title)' - Nueva racha: \(tasks[index].habitStreak)")
                }
            } else {
                tasks[index].completedAt = nil
            }
            
            updateTaskDate(index: index)
            habitService.updateHabits(from: tasks) // Fase 8: Actualizar hábitos
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
        // Fase 8: Limpiar propiedades de hábito
        isHabit = false
        selectedHabitFrequency = .daily
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
        case .habits: // Fase 8: Nuevo filtro para hábitos
            filtered = filtered.filter { $0.isHabit }
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
    
    // Fase 8: Métricas específicas de hábitos
    var habitCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let completedHabits = habits.filter(\.isCompleted).count
        return Double(completedHabits) / Double(habits.count)
    }
    
    var averageHabitStreak: Double {
        guard !habits.isEmpty else { return 0 }
        let totalStreak = habits.reduce(0) { $0 + $1.habitStreak }
        return Double(totalStreak) / Double(habits.count)
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
    case habits = "Hábitos" // Fase 8: Nuevo filtro
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .completed: return "checkmark.circle"
        case .pending: return "circle"
        case .withReminders: return "bell"
        case .habits: return "repeat" // Fase 8
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
            Task(title: "Comprar víveres", categoryId: viewModel.categories[1].id, assignedTo: viewModel.collaborators.first?.id),
            // Fase 8: Hábitos de ejemplo
            Task(title: "Meditar", isHabit: true, habitStreak: 5, habitFrequency: .daily),
            Task(title: "Revisar metas semanales", isHabit: true, habitStreak: 2, habitFrequency: .weekly)
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
