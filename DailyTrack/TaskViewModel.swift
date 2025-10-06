//
//  TaskViewModel.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//
import Foundation

import Foundation

import Foundation

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }

    private let tasksKey = "dailytrack_tasks"

    init() {
        loadTasks()
    }

    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
    }

    func toggleCompleted(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    // MARK: - Persistencia
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}
