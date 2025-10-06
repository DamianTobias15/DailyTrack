//
//  ContentView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 9/26/25.
//  Add element check

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TaskViewModel() // ViewModel en memoria
    @State private var newTaskTitle: String = ""  // texto del TextField

    var body: some View {
        NavigationView {
            VStack {
                // --- Entrada para crear tarea ---
                HStack {
                    TextField("Nueva tarea...", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.sentences)
                        .disableAutocorrection(false)

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Agregar tarea")
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // --- Lista de tareas ---
                List {
                    ForEach(vm.tasks) { task in
                        TaskRowView(task: task) {
                            vm.toggleCompleted(task)
                        }
                    }
                    .onDelete(perform: vm.deleteTask)
                }
                .listStyle(.plain)
            }
            .navigationTitle("DailyTrack")
            .toolbar {
                EditButton()
            }
        }
    }

    // MARK: - Actions
    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        vm.addTask(title: title)
        newTaskTitle = ""
    }
}

// Row reutilizable
struct TaskRowView: View {
    let task: Task
    let toggleAction: () -> Void

    var body: some View {
        HStack {
            Button(action: toggleAction) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Desmarcar tarea" : "Marcar tarea como completada")

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .font(.body)

                // Si en el futuro usas dueDate: mostrarlo aquí
                // if let due = task.dueDate { Text(due, style: .date).font(.caption).foregroundColor(.secondary) }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// Preview
#Preview {
    ContentView()
}

