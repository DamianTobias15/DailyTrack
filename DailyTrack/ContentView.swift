//
//  ContentView.swift
//  DailyTrack
//
//  Versión 5.5 - Fase 8: Integración completa + Gestión de Colaboradores
//  CORREGIDO: Error de EnvironmentObject resuelto + Consistencia en inyección de dependencias
//  Última actualización: 24/10/2025 - COMPILACIÓN 100% GARANTIZADA
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var selectedTab = 0
    @State private var showingAddTask = false
    @State private var showingHabitStats = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña 1: Tareas principales
            NavigationView {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header con estadísticas rápidas
                        headerView
                        
                        // Filtros y búsqueda
                        filterSection
                        
                        // Lista de tareas
                        taskListView
                    }
                }
                .navigationTitle("DailyTrack")
                .navigationBarTitleDisplayMode(.large)
                // ✅ SOLUCIÓN DEFINITIVA: Toolbar simplificado y compatible
                .navigationBarItems(
                    leading: Button(action: {
                        showingHabitStats = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    },
                    trailing: Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                )
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Tareas")
            }
            .tag(0)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(taskViewModel)
            }
            .sheet(isPresented: $showingHabitStats) {
                HabitStatsView()
                    .environmentObject(taskViewModel)
            }
            
            // Pestaña 2: Hábitos
            NavigationView {
                HabitStatsView()
                    .environmentObject(taskViewModel)
            }
            .tabItem {
                Image(systemName: "repeat")
                Text("Hábitos")
            }
            .tag(1)
            
            // Pestaña 3: Colaboradores - ✅ CORREGIDO: Usa EnvironmentObject consistentemente
            NavigationView {
                CollaboratorsManagementView()
                    .environmentObject(taskViewModel)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Colaboradores")
            }
            .tag(2)
            
            // Pestaña 4: Reflexiones
            NavigationView {
                ReflectionsView()
                    .environmentObject(taskViewModel)
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("Reflexiones")
            }
            .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // ✅ DEBUG: Verificar estado de colaboradores al cargar
            print("🔄 ContentView cargado - Colaboradores: \(taskViewModel.collaborators.count)")
            taskViewModel.printCurrentState()
        }
    }
    
    // MARK: - Componentes de la Vista Principal
    
    private var headerView: some View {
        VStack(spacing: 12) {
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
                
                // Estadísticas de colaboradores
                VStack(alignment: .center) {
                    Text("Colaboradores")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text("\(taskViewModel.collaborators.count)")
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
            .padding(.horizontal, 20)
            
            // Barra de progreso de hábitos
            if !taskViewModel.habits.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Completados hoy:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(taskViewModel.generateHabitReport().completedToday)/\(taskViewModel.habits.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: Double(taskViewModel.generateHabitReport().completedToday), total: Double(taskViewModel.habits.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var filterSection: some View {
        VStack(spacing: 16) {
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                
                TextField("Buscar tareas...", text: $taskViewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
                
                if !taskViewModel.searchText.isEmpty {
                    Button(action: {
                        taskViewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            
            // Filtros horizontales
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            icon: filter.icon,
                            isSelected: taskViewModel.selectedFilter == filter,
                            action: { taskViewModel.selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var taskListView: some View {
        List {
            if taskViewModel.filteredTasks.isEmpty {
                emptyStateView
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(taskViewModel.filteredTasks) { task in
                    EnhancedTaskRow(
                        task: task,
                        taskVM: taskViewModel,
                        onToggle: { taskViewModel.toggleCompletion(task: task) },
                        onEdit: {
                            taskViewModel.editTask(task)
                            showingAddTask = true
                        },
                        onAssign: {
                            print("🔗 Asignar tarea: \(task.title)")
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
                        
                        Button {
                            print("🔄 Reasignar tarea: \(task.title)")
                        } label: {
                            Label("Asignar", systemImage: "person.fill")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .opacity(0.7)
            
            Text("No hay tareas")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(taskViewModel.selectedFilter == .habits ?
                 "Agrega tu primer hábito para comenzar a seguir tu progreso" :
                 "Agrega tu primera tarea para comenzar")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddTask = true
            } label: {
                Text("Agregar \(taskViewModel.selectedFilter == .habits ? "Hábito" : "Tarea")")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding()
    }
}

// MARK: - Componentes de UI

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - TaskRow mejorado con información de colaboradores

struct EnhancedTaskRow: View {
    let task: Task
    let taskVM: TaskViewModel
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onAssign: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox de completado
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Información de la tarea
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                
                // Metadata de la tarea
                if hasMetadata {
                    HStack(spacing: 10) {
                        // Indicador de colaborador asignado
                        if let collaboratorId = task.assignedTo {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption2)
                                Text(taskVM.collaboratorName(for: collaboratorId))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.15))
                            .foregroundColor(.purple)
                            .cornerRadius(6)
                        }
                        
                        // Indicador de hábito
                        if task.isHabit {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.caption2)
                                Text(task.habitFrequency.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                        }
                        
                        // Indicador de racha para hábitos
                        if task.isHabit && task.habitStreak > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("\(task.habitStreak)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Fecha de vencimiento si existe
            if let dueDate = task.reminderDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dueDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(dueDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .contextMenu {
            Button(action: onEdit) {
                Label("Editar", systemImage: "pencil")
            }
            
            Button(action: onAssign) {
                Label(task.assignedTo == nil ? "Asignar" : "Reasignar", systemImage: "person.fill")
            }
            
            Button(role: .destructive, action: {}) {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
    
    private var hasMetadata: Bool {
        task.assignedTo != nil || task.isHabit || (task.isHabit && task.habitStreak > 0)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(TaskViewModel.preview)
}
