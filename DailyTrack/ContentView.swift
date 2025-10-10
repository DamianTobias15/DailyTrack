//
//  ContentView.swift
//  DailyTrack
//
//  Version 5.0 - Fase 7: Integración completa de sistema de rachas
//  Last modified: 08/10/2025
//

import SwiftUI

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
                .navigationTitle("DailyTrack")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddTask = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingHabitStats = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $showingAddTask) {
                    AddTaskView()
                        .environmentObject(taskViewModel)
                }
                .sheet(isPresented: $showingHabitStats) {
                    HabitStatsView()
                        .environmentObject(taskViewModel)
                }
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Tareas")
            }
            .tag(0)
            
            // Pestaña de hábitos (nueva)
            NavigationView {
                HabitStatsView()
                    .environmentObject(taskViewModel)
            }
            .tabItem {
                Image(systemName: "repeat")
                Text("Hábitos")
            }
            .tag(1)
            
            // Pestaña de reflexiones (existente)
            NavigationView {
                ReflectionsView()
                    .environmentObject(taskViewModel)
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("Reflexiones")
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
                    .environmentObject(streakVM)
            }
        }
    }
    
    // MARK: - Componentes de la Vista Principal
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                // Estadísticas de hábitos
                VStack(alignment: .leading) {
                    Text("Hábitos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(taskViewModel.habits.count) activos")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Rachas actuales
                VStack(alignment: .trailing) {
                    Text("Racha más larga")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(taskViewModel.generateHabitReport().longestStreak)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("días")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
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
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar tareas...", text: $taskViewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !taskViewModel.searchText.isEmpty {
                    Button {
                        taskViewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Filtros horizontales
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            icon: filter.icon,
                            isSelected: taskViewModel.selectedFilter == filter,
                            action: { taskViewModel.selectedFilter = filter }
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var taskListView: some View {
        List {
            if taskViewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                ForEach(taskViewModel.filteredTasks) { task in
                    TaskRow(
                        task: task,
                        onToggle: { taskViewModel.toggleCompletion(task: task) },
                        onEdit: {
                            taskViewModel.editTask(task)
                            showingAddTask = true
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            taskViewModel.deleteTask(task)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                        
                        Button {
                            taskViewModel.editTask(task)
                            showingAddTask = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
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
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddTask = true
            } label: {
                Text("Agregar \(taskViewModel.selectedFilter == .habits ? "Hábito" : "Tarea")")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
}

// MARK: - Componentes de UI

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox de completado
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Información de la tarea
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                // Metadata de la tarea
                HStack(spacing: 8) {
                    // Indicador de hábito
                    if task.isHabit {
                        HStack(spacing: 2) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text(task.habitFrequency.rawValue)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    }
                    
                    // Indicador de racha para hábitos
                    if task.isHabit && task.habitStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(task.habitStreak)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                    }
                    
                    // Recordatorio
                    if task.reminderDate != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            // Fecha de vencimiento si existe
            if let dueDate = task.reminderDate {
                VStack(alignment: .trailing) {
                    Text(dueDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(dueDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                // La eliminación se maneja desde fuera
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(TaskViewModel.preview)
}
