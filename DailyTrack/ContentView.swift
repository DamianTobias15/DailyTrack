//
//  ContentView.swift
//  DailyTrack
//
//  Version 3.0 - Fase 6: Compatible con TaskViewModel actualizado
//  Last modified: \(Date())
//

import SwiftUI
import Charts

struct ContentView: View {
    // MARK: - ViewModel
    @StateObject private var taskVM = TaskViewModel()
    
    // MARK: - Estados
    @State private var newTaskTitle: String = ""
    @State private var showingAddTask = false
    @State private var showingCategories = false
    @State private var showingReflections = false
    
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
                weeklyChartSection
                taskListSection
            }
            .navigationTitle("Mis Tareas")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            showingCategories = true
                        } label: {
                            Label("Categorías", systemImage: "folder")
                        }
                        
                        Button {
                            showingReflections = true
                        } label: {
                            Label("Reflexiones", systemImage: "book")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
        }
    }
}

// MARK: - Secciones
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
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                taskVM.deleteTask(task)
                            }
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                        
                        Button {
                            taskVM.editTask(task)
                            showingAddTask = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if taskVM.filteredTasks.isEmpty {
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
    }
    
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
                    if let categoryId = task.categoryId,
                       let category = taskVM.category(for: categoryId) {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
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
                    
                    if let collaboratorId = task.assignedTo,
                       let collaborator = taskVM.collaborator(for: collaboratorId) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(collaborator.avatarColor)
                                .frame(width: 12, height: 12)
                            Text(collaborator.initials)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Indicador de recordatorio
            if task.reminderDate != nil {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Vista previa
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskViewModel.preview)
    }
}
