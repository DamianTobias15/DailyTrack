//
//  ContentView.swift
//  DailyTrack
//
//  Version 5.0 - Fase 7: Integración completa de sistema de rachas
//  Last modified: 08/10/2025
//

import SwiftUI
import Charts

struct ContentView: View {
    // MARK: - ViewModels
    @StateObject private var taskVM = TaskViewModel()
    @StateObject private var streakVM: StreakViewModel
    
    // MARK: - Estados
    @State private var newTaskTitle: String = ""
    @State private var showingAddTask = false
    @State private var showingCategories = false
    @State private var showingReflections = false
    @State private var showingCollaborators = false
    @State private var showingTaskAssignment: Task? = nil
    @State private var showingAchievements = false
    
    // MARK: - Inicializador
    init() {
        let taskViewModel = TaskViewModel()
        _taskVM = StateObject(wrappedValue: taskViewModel)
        _streakVM = StateObject(wrappedValue: StreakViewModel(taskVM: taskViewModel))
    }
    
    // MARK: - Propiedades calculadas
    /// Calcula el porcentaje de tareas completadas
    private var completionRate: Double {
        taskVM.completionRate
    }
    
    /// Días de la semana para el gráfico
    private let weekDays = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    
    // MARK: - Cuerpo principal
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                taskInputSection
                progressSection
                streaksSection
                weeklyChartSection
                taskListSection
            }
            .navigationTitle("Mis Tareas")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    mainMenu
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addTaskButton
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingCategories) {
                CategoryListView()
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingReflections) {
                ReflectionsView()
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingCollaborators) {
                CollaboratorsManagementView()
                    .environmentObject(taskVM)
            }
            .sheet(item: $showingTaskAssignment) { task in
                TaskAssignmentView(task: task)
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
                    .environmentObject(streakVM)
            }
        }
    }
}

// MARK: - Componentes de Toolbar
private extension ContentView {
    
    var mainMenu: some View {
        Menu {
            Button {
                showingCategories = true
            } label: {
                Label("Categorías", systemImage: "folder")
            }
            
            Button {
                showingCollaborators = true
            } label: {
                Label("Colaboradores", systemImage: "person.2")
            }
            
            Button {
                showingReflections = true
            } label: {
                Label("Reflexiones", systemImage: "book")
            }
            
            if !streakVM.achievements.isEmpty {
                Button {
                    showingAchievements = true
                } label: {
                    Label("Logros (\(streakVM.achievements.count))", systemImage: "trophy")
                }
            }
            
            Divider()
            
            // Estadísticas rápidas
            Section("Estadísticas") {
                Text("\(taskVM.tasks.count) tareas totales")
                Text("\(taskVM.tasks.filter { $0.isCompleted }.count) completadas")
                Text("\(taskVM.collaborators.count) colaboradores")
                Text("\(streakVM.currentStreak) días de racha")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
        }
    }
    
    var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.title3)
        }
    }
}

// MARK: - Secciones Principales
private extension ContentView {
    
    /// Sección para agregar una nueva tarea
    var taskInputSection: some View {
        HStack {
            TextField("Nueva tarea rápida", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button {
                guard !newTaskTitle.isEmpty else { return }
                withAnimation {
                    taskVM.addTask(title: newTaskTitle)
                    newTaskTitle = ""
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            .padding(.trailing)
            .disabled(newTaskTitle.isEmpty)
        }
    }
    
    /// Sección de progreso general con animación reactiva
    var progressSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Progreso: \(Int(completionRate * 100))%")
                .font(.subheadline)
                .padding(.leading)
            
            ProgressView(value: completionRate)
                .accentColor(.green)
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.5), value: completionRate)
        }
    }
    
    /// Sección de rachas y logros con animaciones
    var streaksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rachas y Progreso")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                // Racha Actual
                VStack {
                    Text("\(streakVM.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(streakVM.currentStreak > 0 ? .orange : .gray)
                        .transition(.scale.combined(with: .opacity))
                    
                    Text("Días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                
                // Racha Más Larga
                VStack {
                    Text("\(streakVM.longestStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Récord")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Progreso Semanal
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progreso Semanal")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(streakVM.weeklyCompletion * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: streakVM.weeklyCompletion)
                    .accentColor(.green)
                    .animation(.easeInOut(duration: 0.5), value: streakVM.weeklyCompletion)
            }
            .padding(.horizontal)
            
            // Botón para ver logros
            if !streakVM.achievements.isEmpty {
                Button {
                    showingAchievements = true
                } label: {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Ver Logros (\(streakVM.achievements.count))")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Gráfico semanal de tareas completadas con animación reactiva
    var weeklyChartSection: some View {
        VStack(alignment: .leading) {
            Text("Tareas completadas esta semana")
                .font(.subheadline)
                .padding(.leading)
            
            Chart {
                ForEach(0..<7, id: \.self) { i in
                    BarMark(
                        x: .value("Día", weekDays[i]),
                        y: .value("Completadas", taskVM.weeklyStats()[i])
                    )
                    .foregroundStyle(.green.gradient)
                }
            }
            .frame(height: 120)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.5), value: taskVM.weeklyStats())
        }
    }
    
    /// Lista interactiva de tareas
    var taskListSection: some View {
        List {
            ForEach(taskVM.filteredTasks) { task in
                taskRow(for: task)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            taskVM.toggleCompletion(task: task)
                            // Actualizar rachas cuando se completa una tarea
                            streakVM.refreshAllCalculations()
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        deleteButton(for: task)
                        editButton(for: task)
                        assignButton(for: task)
                    }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if taskVM.filteredTasks.isEmpty {
                emptyStateView
            }
        }
    }
}

// MARK: - Componentes de Tareas
private extension ContentView {
    
    /// Fila individual de tarea
    func taskRow(for task: Task) -> some View {
        HStack(spacing: 12) {
            // Indicador de completado
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .gray)
                .font(.title3)
                .transition(.scale.combined(with: .opacity))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .green)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .font(.body)
                
                // Información adicional
                HStack(spacing: 8) {
                    categoryBadge(for: task)
                    collaboratorBadge(for: task)
                }
            }
            
            Spacer()
            
            // Indicadores de estado
            HStack(spacing: 8) {
                reminderIndicator(for: task)
                assignmentButton(for: task)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    func categoryBadge(for task: Task) -> some View {
        Group {
            if let categoryId = task.categoryId,
               let category = taskVM.category(for: categoryId) {
                HStack(spacing: 4) {
                    Image(systemName: category.iconName ?? "folder")
                        .font(.caption2)
                    Text(category.name)
                        .font(.caption2)
                }
                .foregroundColor(category.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(category.color.opacity(0.1))
                .cornerRadius(4)
            }
        }
    }
    
    func collaboratorBadge(for task: Task) -> some View {
        Group {
            if let collaboratorId = task.assignedTo,
               let collaborator = taskVM.collaborator(for: collaboratorId) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForCollaborator(collaborator))
                        .frame(width: 12, height: 12)
                    Text(initialsForCollaborator(collaborator))
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
    }
    
    func reminderIndicator(for task: Task) -> some View {
        Group {
            if task.reminderDate != nil {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    func assignmentButton(for task: Task) -> some View {
        Button {
            showingTaskAssignment = task
        } label: {
            Image(systemName: "person.circle")
                .font(.caption)
                .foregroundColor(task.assignedTo != nil ? .blue : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Acciones de Swipe
private extension ContentView {
    
    func deleteButton(for task: Task) -> some View {
        Button(role: .destructive) {
            withAnimation {
                taskVM.deleteTask(task)
            }
        } label: {
            Label("Eliminar", systemImage: "trash")
        }
    }
    
    func editButton(for task: Task) -> some View {
        Button {
            taskVM.editTask(task)
            showingAddTask = true
        } label: {
            Label("Editar", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
    func assignButton(for task: Task) -> some View {
        Button {
            showingTaskAssignment = task
        } label: {
            Label("Asignar", systemImage: "person")
        }
        .tint(.green)
    }
}

// MARK: - Estados Vacíos
private extension ContentView {
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No hay tareas")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Agrega tu primera tarea usando el botón +")
                .font(.body)
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding()
    }
}

// MARK: - Utilidades
private extension ContentView {
    
    func colorForCollaborator(_ collaborator: Collaborator) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .indigo]
        let index = abs(collaborator.id.hashValue) % colors.count
        return colors[index]
    }
    
    func initialsForCollaborator(_ collaborator: Collaborator) -> String {
        let components = collaborator.name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first?.uppercased() }
        
        // SOLUCIÓN SIMPLIFICADA - Evita problemas de inicialización
        var result = ""
        for initial in initials {
            result.append(initial)
        }
        return result
    }
}

// MARK: - Vista previa
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
