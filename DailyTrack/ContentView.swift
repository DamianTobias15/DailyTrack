//
//  ContentView.swift
//  DailyTrack
//
//  Version 1.4 - Fase 5: Añadido gráfico semanal con SwiftUI Charts
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var taskVM = TaskViewModel()
    @State private var newTaskTitle: String = ""
    
    private var completionRate: Double {
        guard !taskVM.tasks.isEmpty else { return 0 }
        let completed = taskVM.tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(taskVM.tasks.count)
    }
    
    // Etiquetas de días de la semana
    private let weekDays = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Campo de texto y botón para agregar tarea
                HStack {
                    TextField("Nueva tarea", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        withAnimation { taskVM.addTask(title: newTaskTitle) }
                        newTaskTitle = ""
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.trailing)
                }
                
                // Barra de progreso
                VStack(alignment: .leading) {
                    Text("Progreso: \(Int(completionRate * 100))%")
                        .font(.subheadline)
                        .padding(.leading)
                    ProgressView(value: completionRate)
                        .accentColor(.green)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: completionRate)
                }
                .padding(.vertical, 5)
                
                // Gráfica semanal
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
                }
                
                // Lista de tareas
                List {
                    ForEach(taskVM.tasks.indices, id: \.self) { index in
                        HStack {
                            Text(taskVM.tasks[index].title)
                                .strikethrough(taskVM.tasks[index].isCompleted, color: .green)
                                .foregroundColor(taskVM.tasks[index].isCompleted ? .gray : .primary)
                            Spacer()
                            if taskVM.tasks[index].isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.scale)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                taskVM.toggleTaskCompletion(index: index)
                            }
                        }
                    }
                    .onDelete(perform: taskVM.deleteTask)
                }
            }
            .navigationTitle("Mis Tareas")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
